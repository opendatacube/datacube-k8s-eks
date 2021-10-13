resource "kubernetes_service" "db_endpoint_web_ns" {
  metadata {
    name      = "db-endpoint"
    namespace = kubernetes_namespace.web.metadata[0].name
  }
  spec {
    type          = "ExternalName"
    external_name = local.db_hostname
  }
  wait_for_load_balancer = false
}

resource "kubernetes_service" "db_endpoint_service_ns" {
  metadata {
    name      = "db-endpoint"
    namespace = kubernetes_namespace.service.metadata[0].name
  }
  spec {
    type          = "ExternalName"
    external_name = local.db_hostname
  }
  wait_for_load_balancer = false
}