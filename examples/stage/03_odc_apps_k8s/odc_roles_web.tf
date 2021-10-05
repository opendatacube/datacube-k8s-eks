# Roles for k8s web applications
# Separate TF files can be used per application but in some cases it
# is more manageable to simply group them up (e.g. Use the odc_roles and a list of roles)

data "aws_iam_policy_document" "ows_trust_policy" {
  statement {
    resources = ["arn:aws:s3:::dea-public-data"]
    actions   = ["S3:ListBucket"]
  }
  statement {
    resources = ["arn:aws:s3:::dea-public-data/*"]
    actions   = ["S3:GetObject"]
  }
}

module "odc_role_ows" {
  //  source = "github.com/opendatacube/datacube-k8s-eks//odc_role?ref=master"
  source = "../../../odc_k8s_service_account_role"

  # Default Tags
  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment
  oidc_arn    = aws_iam_openid_connect_provider.identity_provider_example.arn
  oidc_url    = aws_iam_openid_connect_provider.identity_provider_example.url

  service_account_role = {
    name                      = "${local.cluster_id}-ows"
    service_account_namespace = kubernetes_namespace.web.metadata[0].name
    service_account_name      = "*"
    policy                    = data.aws_iam_policy_document.ows_trust_policy.json
  }
}
