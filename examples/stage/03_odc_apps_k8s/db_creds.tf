# Create a db secrets in "web" namespace
resource "kubernetes_secret" "ows_db" {
  metadata {
    name      = "ows-db"
    namespace = kubernetes_namespace.web.metadata[0].name
  }

  data = {
    postgres-username = local.ows_db_username
    postgres-password = local.ows_db_password
  }

  type = "Opaque"
}