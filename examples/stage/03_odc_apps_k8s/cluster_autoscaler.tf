data "aws_iam_policy_document" "autoscaler_trust_policy" {
  statement {
    resources = ["*"]
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions"
    ]
  }
}

module "odc_role_autoscaler" {
  //  source = "github.com/opendatacube/datacube-k8s-eks//odc_k8s_service_account_role?ref=master"
  source = "../../../odc_k8s_service_account_role"

  # Default Tags
  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment
  oidc_arn    = local.oidc_arn
  oidc_url    = local.oidc_url

  service_account_role = {
    name                      = "${local.cluster_id}-autoscaler"
    service_account_namespace = kubernetes_namespace.admin.metadata[0].name
    service_account_name      = "*"
    policy                    = data.aws_iam_policy_document.autoscaler_trust_policy.json
  }
}

data "template_file" "cluster_autoscaler" {
  template = file("${path.module}/config/cluster_autoscaler.yaml")
  vars = {
    cluster_name = local.cluster_id
    region       = local.region
    role_name    = module.odc_role_autoscaler.role_name
  }
}

resource "kubernetes_secret" "cluster_autoscaler" {
  depends_on = [
    kubernetes_namespace.admin
  ]

  metadata {
    name      = "cluster-autoscaler"
    namespace = kubernetes_namespace.admin.metadata[0].name
  }

  data = {
    "values.yaml" = data.template_file.cluster_autoscaler.rendered
  }

  type = "Opaque"
}
