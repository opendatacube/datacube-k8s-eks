data "aws_route53_zone" "domain" {
  name = local.domain_name
}

data "template_file" "external_dns" {
  template = file("${path.module}/config/external_dns.yaml")
  vars = {
    cluster_name   = local.cluster_id
    hosted_zone_id = data.aws_route53_zone.domain.zone_id
    domain_name    = local.domain_name
    role_name      = module.odc_role_external_dns.role_name
  }
}

resource "kubernetes_secret" "external_dns" {
  depends_on = [
    kubernetes_namespace.admin
  ]

  metadata {
    name      = "external-dns"
    namespace = resource.kubernetes_namespace.admin.metadata[0].name
  }

  data = {
    "values.yaml" = data.template_file.external_dns.rendered
  }

  type = "Opaque"
}
