# Metrics Server - Provides metrics information for tools like HPA
# ==================================

variable "metrics_server_enabled" {
  default = false
}

resource "helm_release" "metrics_server" {
  count      = "${var.metrics_server_enabled ? 1 : 0}"
  name       = "metrics-server"
  repository = "${data.helm_repository.stable.metadata.0.name}"
  chart      = "metrics-server"
  namespace  = "kube-system"

  values = [
    "${file("${path.module}/config/metrics-server.yaml")}",
  ]

  depends_on = ["kubernetes_service_account.tiller",
                "kubernetes_cluster_role_binding.tiller_clusterrolebinding",
                "null_resource.helm_init_client"]
}
