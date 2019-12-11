resource "kubernetes_secret" "db_creds" {
  count = var.store_db_creds ? 1 : 0

  metadata {
    name = aws_eks_cluster.eks.name
  }

  data = {
    postgres-username = var.db_admin_username
    postgres-password = var.db_admin_password
  }

  type = "Opaque"
}
