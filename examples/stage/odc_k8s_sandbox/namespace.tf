resource "kubernetes_namespace" "sandbox" {
  metadata {
    name = "sandbox"

    labels = {
      managed-by = "Terraform"
    }
  }
}