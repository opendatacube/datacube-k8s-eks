data "aws_iam_policy_document" "fluentd_trust_policy" {
  statement {
    resources = ["*"]
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup"
    ]
  }
}

module "odc_role_fluentd" {
  //  source = "github.com/opendatacube/datacube-k8s-eks//odc_k8s_service_account_role?ref=master"
  source = "../../../odc_k8s_service_account_role"

  # Default Tags
  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment
  oidc_arn    = local.oidc_arn
  oidc_url    = local.oidc_url

  service_account_role = {
    name                      = "${local.cluster_id}-fluentd"
    service_account_namespace = kubernetes_namespace.admin.metadata[0].name
    service_account_name      = "*"
    policy                    = data.aws_iam_policy_document.fluentd_trust_policy.json
  }
}

data "template_file" "fluentd_cloudwatch" {
  template = file("${path.module}/config/fluentd_cloudwatch.yaml")
  vars = {
    cluster_name        = local.cluster_id
    region              = local.region
    service_account_arn = module.odc_role_fluentd.role_name
  }
}

resource "kubernetes_secret" "fluentd_cloudwatch" {
  metadata {
    name      = "fluentd-cloudwatch"
    namespace = kubernetes_namespace.admin.metadata[0].name
  }

  data = {
    "values.yaml" = data.template_file.fluentd_cloudwatch.rendered
  }

  type = "Opaque"
}
