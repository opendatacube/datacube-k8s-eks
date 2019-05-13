resource "helm_release" "metrics_server" {
  count      = "${var.metrics_server_enabled ? 1 : 0}"
  name       = "metrics-server"
  repository = "${data.helm_repository.stable.metadata.0.name}"
  chart      = "metrics-server"
  namespace  = "kube-system"

  values = [
    "${file("${path.module}/config/metrics-server.yaml")}",
  ]
}
