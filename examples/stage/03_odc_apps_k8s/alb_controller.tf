data "aws_iam_policy_document" "alb_controller_trust_policy" {
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
      "cognito-idp:DescribeUserPoolClient"
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
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL"
    ]
  }
  statement {
    resources = ["*"]
    actions = [
      "shield:DescribeProtection",
      "shield:GetSubscriptionState",
      "shield:DeleteProtection",
      "shield:CreateProtection",
      "shield:DescribeSubscription",
      "shield:ListProtections"
    ]
  }
  statement {
    resources = ["arn:aws:ec2:*:*:security-group/*"]
    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags"
    ]
    condition {
      test     = "StringEquals"
      values   = ["false"]
      variable = "aws:ResourceTag/ingress.k8s.aws/cluster"
    }
  }
  statement {
    resources = [
      "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
    ]
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:DeleteTargetGroup"
    ]
    condition {
      test     = "StringEquals"
      values   = ["false"]
      variable = "aws:ResourceTag/ingress.k8s.aws/cluster"
    }
  }
}

module "odc_role_alb_controller" {
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
    name                      = "${local.cluster_id}-alb-controller"
    service_account_namespace = kubernetes_namespace.admin.metadata[0].name
    service_account_name      = "*"
    policy                    = data.aws_iam_policy_document.alb_controller_trust_policy.json
  }
}

data "template_file" "alb_controller" {
  template = file("${path.module}/config/alb_controller.yaml")
  vars = {
    cluster_name        = local.cluster_id
    service_account_arn = module.odc_role_alb_controller.role_arn
  }
}

resource "kubernetes_secret" "alb_controller" {
  metadata {
    name      = "alb-controller"
    namespace = kubernetes_namespace.admin.metadata[0].name
  }

  data = {
    "values.yaml" = data.template_file.alb_controller.rendered
  }

  type = "Opaque"
}
