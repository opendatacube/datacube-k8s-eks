# Roles for k8s admin applications
# Separate TF files can be used per application but in some cases it
# is more manageable to simply group them up (e.g. Use the odc_roles and a list of roles)

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

data "aws_iam_policy_document" "alb_ingress_trust_policy" {
  statement {
    resources = ["*"]
    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate"
    ]
  }
  statement {
    resources = ["*"]
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcs",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:RevokeSecurityGroupIngress"
    ]
  }
  statement {
    resources = ["*"]
    actions = [
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:SetWebACL"
    ]
  }
  statement {
    resources = ["*"]
    actions = [
      "iam:CreateServiceLinkedRole",
      "iam:GetServerCertificate",
      "iam:ListServerCertificates"
    ]
  }
  statement {
    resources = ["*"]
    actions = [
      "waf-regional:GetWebACLForResource",
      "waf-regional:GetWebACL",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL"
    ]
  }
  statement {
    resources = ["*"]
    actions = [
      "tag:GetResources",
      "tag:TagResources"
    ]
  }
  statement {
    resources = ["*"]
    actions   = ["waf:GetWebACL"]
  }
  statement {
    resources = ["*"]
    actions = [
      "acm:ListCertificates",
      "acm:DescribeCertificate",
      "acm:GetCertificate"
    ]
  }
  statement {
    resources = ["*"]
    actions   = ["cognito-idp:DescribeUserPoolClient"]
  }
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

module "odc_role_autoscaler" {
  //  source = "github.com/opendatacube/datacube-k8s-eks//odc_role?ref=master"
  source = "../../../odc_k8s_service_account_role"

  # Default Tags
  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment
  oidc_arn    = aws_iam_openid_connect_provider.identity_provider_example.arn
  oidc_url    = aws_iam_openid_connect_provider.identity_provider_example.url

  service_account_role = {
    name                      = "${local.cluster_id}-autoscaler"
    service_account_namespace = resource.kubernetes_namespace.admin.metadata[0].name
    service_account_name      = "*"
    policy                    = data.aws_iam_policy_document.autoscaler_trust_policy.json
  }
}

module "odc_role_alb_ingress" {
  //  source = "github.com/opendatacube/datacube-k8s-eks//odc_role?ref=master"
  source = "../../../odc_k8s_service_account_role"

  # Default Tags
  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment
  oidc_arn    = aws_iam_openid_connect_provider.identity_provider_example.arn
  oidc_url    = aws_iam_openid_connect_provider.identity_provider_example.url

  service_account_role = {
    name                      = "${local.cluster_id}-alb-ingress"
    service_account_namespace = resource.kubernetes_namespace.admin.metadata[0].name
    service_account_name      = "*"
    policy                    = data.aws_iam_policy_document.alb_ingress_trust_policy.json
  }
}

module "odc_role_external_dns" {
  //  source = "github.com/opendatacube/datacube-k8s-eks//odc_role?ref=master"
  source = "../../../odc_k8s_service_account_role"

  # Default Tags
  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment
  oidc_arn    = aws_iam_openid_connect_provider.identity_provider_example.arn
  oidc_url    = aws_iam_openid_connect_provider.identity_provider_example.url

  service_account_role = {
    name                      = "${local.cluster_id}-external-dns"
    service_account_namespace = resource.kubernetes_namespace.admin.metadata[0].name
    service_account_name      = "*"
    policy                    = data.aws_iam_policy_document.external_dns_trust_policy.json
  }
}

module "odc_role_fluentd" {
  //  source = "github.com/opendatacube/datacube-k8s-eks//odc_role?ref=master"
  source = "../../../odc_k8s_service_account_role"

  # Default Tags
  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment
  oidc_arn    = aws_iam_openid_connect_provider.identity_provider_example.arn
  oidc_url    = aws_iam_openid_connect_provider.identity_provider_example.url

  service_account_role = {
    name                      = "${local.cluster_id}-fluentd"
    service_account_namespace = resource.kubernetes_namespace.admin.metadata[0].name
    service_account_name      = "*"
    policy                    = data.aws_iam_policy_document.fluentd_trust_policy.json
  }
}
