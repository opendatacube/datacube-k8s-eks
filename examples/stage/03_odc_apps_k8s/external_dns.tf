data "aws_route53_zone" "domain" {
  name = local.domain_name
}

data "aws_iam_policy_document" "external_dns_trust_policy" {
  statement {
    resources = ["arn:aws:route53:::hostedzone/*"]
    actions   = ["route53:ChangeResourceRecordSets"]
  }
  statement {
    resources = ["*"]
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]
  }
}

module "odc_role_external_dns" {
  //  source = "github.com/opendatacube/datacube-k8s-eks//odc_k8s_service_account_role?ref=master"
  source = "../../../odc_k8s_service_account_role"

  # Default Tags
  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment

  # OIDC
  oidc_arn = local.oidc_arn
  oidc_url = local.oidc_url

  # Additional Tags
  tags = local.tags

  service_account_role = {
    name                      = "${local.cluster_id}-external-dns"
    service_account_namespace = kubernetes_namespace.admin.metadata[0].name
    service_account_name      = "*"
    policy                    = data.aws_iam_policy_document.external_dns_trust_policy.json
  }
}

data "template_file" "external_dns" {
  template = file("${path.module}/config/external_dns.yaml")
  vars = {
    cluster_name        = local.cluster_id
    hosted_zone_id      = data.aws_route53_zone.domain.zone_id
    domain_name         = local.domain_name
    service_account_arn = module.odc_role_external_dns.role_arn
  }
}

resource "kubernetes_secret" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = kubernetes_namespace.admin.metadata[0].name
  }

  data = {
    "values.yaml" = data.template_file.external_dns.rendered
  }

  type = "Opaque"
}
