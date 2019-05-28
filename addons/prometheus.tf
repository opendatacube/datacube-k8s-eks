# Prometheus - View and alert on metrics
# ==================================

variable "prometheus_enabled" {
  default = false
}

resource "kubernetes_namespace" "monitoring" {
  count = "${var.prometheus_enabled ? 1 : 0}"

  metadata {
    name = "monitoring"

    labels {
      managed-by = "Terraform"
    }
  }
}

# Create the prometheus operator, configure grafana dashboard ingress
resource "helm_release" "prometheus_operator" {
  count      = "${var.prometheus_enabled  ? 1 : 0}"
  name       = "prometheus-operator"
  repository = "stable"
  chart      = "prometheus-operator"
  namespace  = "monitoring"

  values = [<<EOF
grafana:
  ingress:
    enabled: ${var.alb_ingress_enabled}
    annotations:
      kubernetes.io/ingress.class: alb
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/target-type: ip
      alb.ingress.kubernetes.io/healthcheck-path: "/metrics"
      alb.ingress.kubernetes.io/certificate-arn: "${aws_acm_certificate_validation.wildcard_cert.0.certificate_arn}"
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
    hosts: 
      - mgmt.${var.domain_name}
    path: /*
  env:
    GF_SERVER_ROOT_URL: https://mgmt.${var.domain_name}/
  # force chart to generate password as prometheus-operator-grafana secret
  adminPassword: null
EOF
  ]

  depends_on = ["kubernetes_namespace.monitoring",
    "kubernetes_service_account.tiller",
    "kubernetes_cluster_role_binding.tiller_clusterrolebinding",
    "null_resource.helm_init_client",
  ]

  # Cleanup crds
  provisioner "local-exec" {
    when    = "destroy"
    command = "kubectl delete crd/prometheuses.monitoring.coreos.com"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "kubectl delete crd/prometheusrules.monitoring.coreos.com"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "kubectl delete crd/servicemonitors.monitoring.coreos.com"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "kubectl delete crd/alertmanagers.monitoring.coreos.com"
  }
}
