resource "kubernetes_secret" "db_creds" {
  count = var.store_db_creds ? 1 : 0

  metadata {
    name = var.cluster_id
  }

  data = {
    postgres-username = var.db_admin_username
    postgres-password = var.db_admin_password
  }

  type = "Opaque"
}

