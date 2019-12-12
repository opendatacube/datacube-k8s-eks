# Metrics Server - Provides metrics information for tools like HPA
# ==================================

variable "metrics_server_enabled" {
  default = false
}

resource "helm_release" "metrics_server" {
  count      = var.metrics_server_enabled ? 1 : 0
  name       = "metrics-server"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "metrics-server"
  namespace  = "kube-system"

  values = [
    file("${path.module}/config/metrics-server.yaml"),
  ]

  depends_on = [
    # module.tiller,
  ]
}

