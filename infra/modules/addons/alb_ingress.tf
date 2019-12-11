# ======================================
# ALB Ingress controller
resource "kubernetes_namespace" "ingress-controller" {
  count = var.alb_ingress_enabled ? 1 : 0

  metadata {
    name = "ingress-controller"

    labels = {
      managed-by = "Terraform"
    }
  }
}

resource "helm_release" "alb-ingress" {
  count      = var.alb_ingress_enabled ? 1 : 0
  name       = "alb-ingress"
  repository = "https://kubernetes-charts-incubator.storage.googleapis.com/"
#  repository = "incubator"
  chart      = "aws-alb-ingress-controller"
  namespace  = "ingress-controller"

  values = [
    file("${path.module}/config/alb-ingress.yaml"),
  ]

  set {
    name  = "clusterName"
    value = var.cluster_id
  }

  set {
    name  = "podAnnotations.iam\\.amazonaws\\.com/role"
    value = "${var.cluster_id}-alb"
  }

  # Uses kube2iam for credentials
  depends_on = [
    helm_release.kube2iam,
    aws_iam_role.alb,
    aws_iam_role_policy.alb,
    kubernetes_namespace.ingress-controller,
    module.tiller,
  ]
}

resource "aws_iam_role" "alb" {
  count = var.alb_ingress_enabled ? 1 : 0
  name  = "${var.cluster_id}-alb"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/nodes.${var.cluster_id}"
        },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "alb" {
  count = var.alb_ingress_enabled ? 1 : 0
  name = "${var.cluster_id}-alb"
  role = aws_iam_role.alb[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "acm:DescribeCertificate",
        "acm:ListCertificates",
        "acm:GetCertificate"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
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
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
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
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole",
        "iam:GetServerCertificate",
        "iam:ListServerCertificates"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "tag:GetResources",
        "tag:TagResources"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf:GetWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "acm:ListCertificates",
        "acm:DescribeCertificate",
        "acm:GetCertificate"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cognito-idp:DescribeUserPoolClient"
      ],
      "Resource": "*"
    }
  ]
}
EOF

}

# Create a wildcard cert for use on the alb
resource "aws_acm_certificate" "wildcard_cert" {
count             = var.alb_ingress_enabled ? 1 : 0
domain_name       = "*.${var.domain_name}"
validation_method = "DNS"
}

# Automatically validate the cert using DNS validation
data "aws_route53_zone" "wildcard_zone" {
count        = var.alb_ingress_enabled ? 1 : 0
name         = var.domain_name
private_zone = false
}

resource "aws_route53_record" "wildcard_cert_validation" {
count   = var.alb_ingress_enabled ? 1 : 0
name    = aws_acm_certificate.wildcard_cert[0].domain_validation_options[0].resource_record_name
type    = aws_acm_certificate.wildcard_cert[0].domain_validation_options[0].resource_record_type
zone_id = data.aws_route53_zone.wildcard_zone[0].id
records = [aws_acm_certificate.wildcard_cert[0].domain_validation_options[0].resource_record_value]
ttl     = 60
}

resource "aws_acm_certificate_validation" "wildcard_cert" {
count                   = var.alb_ingress_enabled ? 1 : 0
certificate_arn         = aws_acm_certificate.wildcard_cert[0].arn
validation_record_fqdns = [aws_route53_record.wildcard_cert_validation[0].fqdn]
}

