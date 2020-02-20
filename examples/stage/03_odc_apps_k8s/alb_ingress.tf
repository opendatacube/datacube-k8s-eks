data "template_file" "alb_ingress" {
  template = file("${path.module}/config/alb_ingress.yaml")
  vars = {
    cluster_name = local.cluster_id
    role_name = module.odc_role_alb_ingress.role_name
  }
}

resource "kubernetes_secret" "alb_ingress" {
  depends_on = [
    kubernetes_namespace.admin
  ]

  metadata {
    name = "alb-ingress"
    namespace = "admin"
  }

  data = {
    "values.yaml" = data.template_file.alb_ingress.rendered
  }

  type = "Opaque"
}