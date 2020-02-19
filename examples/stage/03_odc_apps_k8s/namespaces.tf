resource "kubernetes_namespace" "admin" {
  metadata {
    name = "admin"

    labels = {
      managed-by = "Terraform"
    }
  }
}