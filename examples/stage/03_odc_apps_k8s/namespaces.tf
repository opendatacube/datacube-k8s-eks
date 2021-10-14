resource "kubernetes_namespace" "admin" {
  metadata {
    name = "admin"

    labels = {
      managed-by = "Terraform"
    }
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"

    labels = {
      managed-by = "Terraform"
    }
  }
}

resource "kubernetes_namespace" "web" {
  metadata {
    name = "web"

    labels = {
      managed-by = "Terraform"
    }
  }
}

resource "kubernetes_namespace" "service" {
  metadata {
    name = "service"

    labels = {
      managed-by = "Terraform"
    }
  }
}