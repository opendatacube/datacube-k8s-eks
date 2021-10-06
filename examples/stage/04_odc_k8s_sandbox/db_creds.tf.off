resource "kubernetes_secret" "sandbox_db_ro" {
  metadata {
    name      = "sandbox-db-ro"
    namespace = kubernetes_namespace.sandbox.metadata[0].name
  }

  data = {
    postgres-username = local.sandbox_db_ro_username
    postgres-password = local.sandbox_db_ro_password
  }

  type = "Opaque"
}