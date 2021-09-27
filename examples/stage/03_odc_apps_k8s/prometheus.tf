data "template_file" "prometheus" {
  template = file("${path.module}/config/prometheus.yaml")
  vars = {
    certificate_arn = local.certificate_arn
    domain_name     = local.domain_name
  }
}

resource "kubernetes_secret" "prometheus-operator" {
  depends_on = [
    kubernetes_namespace.admin
  ]

  metadata {
    name      = "prometheus-operator"
    namespace = resource.kubernetes_namespace.admin.metadata[0].name
  }

  data = {
    "values.yaml" = data.template_file.prometheus.rendered
  }

  type = "Opaque"
}
