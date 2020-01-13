# Roles for k8s admin applications
# Separate TF files can be used per application but in some cases it
# is more manageable to simply group them up (e.g. Use the odc_roles and a list of roles)

module "odc_admin_roles" {
//  source = "github.com/opendatacube/datacube-k8s-eks//odc_roles?ref=terraform-aws-odc"
  source = "../../../odc_roles"

  owner = local.owner
  namespace = local.namespace
  environment = local.environment

  cluster_name = local.cluster_name

  roles = [
    {
      name   = "autoscaler"
      policy = <<-EOF
        {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Effect": "Allow",
              "Action": [
                  "autoscaling:DescribeAutoScalingGroups",
                  "autoscaling:DescribeAutoScalingInstances",
                  "autoscaling:DescribeLaunchConfigurations",
                  "autoscaling:DescribeTags",
                  "autoscaling:SetDesiredCapacity",
                  "autoscaling:TerminateInstanceInAutoScalingGroup",
                  "ec2:DescribeLaunchTemplateVersions"
              ],
              "Resource": "*"
            }
          ]
        }
        EOF
    },
    {
      name   = "alb-ingress"
      policy = <<-EOF
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
    },
    {
      name   = "external-dns"
      policy = <<-EOF
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Action": [
              "route53:ChangeResourceRecordSets"
            ],
            "Resource": [
              "arn:aws:route53:::hostedzone/*"
            ]
          },
          {
            "Effect": "Allow",
            "Action": [
              "route53:ListHostedZones",
              "route53:ListResourceRecordSets"
            ],
            "Resource": [
              "*"
            ]
          }
        ]
      }
      EOF
    },
    {
      name   = "fluentd"
      policy = <<-EOF
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Action": [
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "logs:DescribeLogGroups",
              "logs:DescribeLogStreams",
              "logs:CreateLogGroup"
            ],
            "Resource": [
              "*"
            ]
          }
        ]
      }
      EOF
    }
  ]
}