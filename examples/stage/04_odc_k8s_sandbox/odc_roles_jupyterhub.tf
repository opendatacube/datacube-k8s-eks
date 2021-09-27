# Roles for Jupyterhub web applications

data "aws_iam_policy_document" "jupyterhub_trust_policy" {
  statement {
    actions   = ["S3:ListBucket"]
    resources = ["arn:aws:s3:::dea-public-data"]
  }
  statement {
    actions   = ["S3:GetObject"]
    resources = ["arn:aws:s3:::dea-public-data/*"]
  }
}

module "odc_role_jupyterhub" {
  # source = "github.com/opendatacube/datacube-k8s-eks//odc_role?ref=master"
  source = "../../../odc_role"

  # Default Tags
  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment

  cluster_id = local.cluster_id

  role = {
    name   = "${local.cluster_id}-jhub"
    policy = data.aws_iam_policy_document.jupyterhub_trust_policy.json
  }
}
