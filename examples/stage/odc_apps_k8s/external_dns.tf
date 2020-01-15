data "aws_route53_zone" "domain" {
  name         = local.domain_name
}

data "template_file" "external_dns" {
  template = file("${path.module}/config/external_dns.yaml")
  vars = {
    cluster_name = local.cluster_name
    hosted_zone_id = data.aws_route53_zone.domain.zone_id
    domain_name = local.domain_name
    role_name = "${local.cluster_name}-external-dns"
  }
}

resource "kubernetes_secret" "external_dns" {
  depends_on = [
    kubernetes_namespace.admin
  ]

  metadata {
    name = "external-dns"
    namespace = "admin"
  }

  data = {
    "values.yaml" = data.template_file.external_dns.rendered
  }

  type = "Opaque"
}