resource "kubernetes_service" "db_endpoint_sandbox_ns" {
  count = local.db_enabled ? 1 : 0
  metadata {
    name      = "db-endpoint"
    namespace = kubernetes_namespace.sandbox.metadata[0].name
  }
  spec {
    type          = "ExternalName"
    external_name = local.db_hostname
  }
  wait_for_load_balancer = false
}