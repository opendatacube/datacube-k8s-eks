# Create a db secrets in "web" namespace
resource "kubernetes_secret" "ows_db_ro" {
  metadata {
    name      = "ows-db-ro"
    namespace = kubernetes_namespace.web.metadata[0].name
  }

  data = {
    postgres-username = local.ows_db_ro_username
    postgres-password = local.ows_db_ro_password
  }

  type = "Opaque"
}