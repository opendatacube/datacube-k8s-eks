resource "kubernetes_secret" "db" {
  depends_on = [
    kubernetes_namespace.sandbox
  ]

  metadata {
    name      = "db"
    namespace = kubernetes_namespace.sandbox.metadata[0].name
  }

  data = {
    postgres-username = local.db_username
    postgres-password = local.db_password
  }

  type = "Opaque"
}
