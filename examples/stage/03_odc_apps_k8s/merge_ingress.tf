data "template_file" "merge_ingress" {
  template = file("${path.module}/config/merge_ingress.yaml")
  vars = {
    certificate_arn = local.certificate_arn
  }
}

resource "kubernetes_config_map" "merge_ingress" {
  metadata {
    name      = "merged-ingress"
    namespace = kubernetes_namespace.web.metadata[0].name
  }

  data = {
    "annotations" = data.template_file.merge_ingress.rendered
  }
}