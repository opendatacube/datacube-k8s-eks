# Flux service account role
data "aws_iam_policy_document" "flux_trust_policy" {
  statement {
    resources = ["*"]
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings"
    ]
  }
}

module "role_flux" {
  source = "../../../odc_k8s_service_account_role"

  # Default Tags
  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment

  #OIDC
  oidc_arn = aws_iam_openid_connect_provider.identity_provider.arn
  oidc_url = aws_iam_openid_connect_provider.identity_provider.url

  service_account_role = {
    name                      = "${local.cluster_id}-flux"
    service_account_namespace = "flux"
    service_account_name      = "*"
    policy                    = data.aws_iam_policy_document.flux_trust_policy.json
  }
}
