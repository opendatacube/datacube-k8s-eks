# BITNAMI KUBEWATCH CONTAINER HELM CHARTS
# =======================================

variable "kubewatch_enabled" {
  description = "Kubewatch flag when enabled shall alert Slack about helm activities"
  type        = bool
  default = false
}

resource "kubernetes_namespace" "monitoring" {
  count = var.kubewatch_enabled ? 1 : 0

  metadata {
    name = "monitoring"

    labels = {
      managed-by = "Terraform"
    }
  }
}

# Create the kubewatch operator, configure grafana dashboard ingress
resource "helm_release" "kubewatch_operator" {
  count      = var.kubewatch_enabled ? 1 : 0
  name       = "kubewatch"
  repository = "stable"
  chart      = "kubewatch"
  namespace  = "monitoring"

  # Cleanup
  provisioner "local-exec" {
    when    = destroy
    command = "helm delete --purge kubewatch"
  }

  depends_on = [
    kubernetes_namespace.monitoring,
    kubernetes_service_account.tiller,
    kubernetes_cluster_role_binding.tiller_clusterrolebinding,
    null_resource.helm_init_client
    ]

}
