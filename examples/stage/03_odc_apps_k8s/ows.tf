data "template_file" "ows" {
  template = file("${path.module}/config/ows.yaml")
  vars = {
    domain_name = local.domain_name

    db_name     = local.ows_db_name
    db_hostname = local.db_hostname
    db_secret   = local.db_enabled ? kubernetes_secret.ows_db_ro[0].metadata[0].name : ""
  }
}

resource "kubernetes_secret" "ows" {
  count = local.db_enabled ? 1 : 0
  metadata {
    name      = "ows"
    namespace = kubernetes_namespace.web.metadata[0].name
  }

  data = {
    "values.yaml" = data.template_file.ows.rendered
  }

  type = "Opaque"
}