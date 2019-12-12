# Prometheus - View and alert on metrics
# ==================================

variable "prometheus_enabled" {
  default = false
}

resource "kubernetes_namespace" "monitoring" {
  count = var.prometheus_enabled ? 1 : 0

  metadata {
    name = "monitoring"

    labels = {
      managed-by = "Terraform"
    }
  }
}

# Create the prometheus operator, configure grafana dashboard ingress
resource "helm_release" "prometheus_operator" {
  count      = var.prometheus_enabled ? 1 : 0
  name       = "prometheus-operator"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "prometheus-operator"
  namespace  = "monitoring"

  values = [
    <<EOF
grafana:
  ingress:
    enabled: ${var.alb_ingress_enabled}
    annotations:
      kubernetes.io/ingress.class: alb
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/target-type: ip
      alb.ingress.kubernetes.io/healthcheck-path: "/metrics"
      alb.ingress.kubernetes.io/certificate-arn: "${aws_acm_certificate_validation.wildcard_cert[0].certificate_arn}"
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
    hosts: 
      - mgmt.${var.domain_name}
    path: /*
  env:
    GF_SERVER_ROOT_URL: https://mgmt.${var.domain_name}/
  # force chart to generate password as prometheus-operator-grafana secret
  adminPassword: null
EOF
,
]

depends_on = [
kubernetes_namespace.monitoring,
# module.tiller,
aws_acm_certificate_validation.wildcard_cert,
helm_release.external-dns,
helm_release.alb-ingress
]

# Cleanup crds
# Cleanup crds
# TOOD local-exec won't work with TF Cloud. Refactor to remove this though move to Flux CD should resolve
# provisioner "local-exec" {
# when = destroy
# command = "kubectl delete crd/prometheuses.monitoring.coreos.com"
# }

# provisioner "local-exec" {
# when = destroy
# command = "kubectl delete crd/prometheusrules.monitoring.coreos.com"
# }

# provisioner "local-exec" {
# when = destroy
# command = "kubectl delete crd/servicemonitors.monitoring.coreos.com"
# }

# provisioner "local-exec" {
# when = destroy
# command = "kubectl delete crd/podmonitors.monitoring.coreos.com"
# }

# provisioner "local-exec" {
# when = destroy
# command = "kubectl delete crd/alertmanagers.monitoring.coreos.com"
# }
}

