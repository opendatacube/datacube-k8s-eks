# ======================================
# External DNS
variable "external_dns_enabled" {
  default = false
}

resource "helm_release" "external-dns" {
    count      = "${var.external_dns_enabled ? 1 : 0}"
    name       = "external-dns"
    repository = "${data.helm_repository.stable.metadata.0.name}"
    chart      = "stable/external-dns"
    namespace = "ingress-controller"

    values = [
        "${file("${path.module}/config/external-dns.yaml")}"
    ]

    set {
      name = "podAnnotations.iam\\.amazonaws\\.com/role"
      value = "${var.cluster_name}-external-dns"
    }

    # Uses kube2iam for credentials
    depends_on = ["helm_release.kube2iam", "aws_iam_role.external_dns", "aws_iam_role_policy.external_dns", "kubernetes_namespace.ingress-controller"]
}

resource "aws_iam_role" "external_dns" {
  count = "${var.external_dns_enabled}"
  name  = "${var.cluster_name}-external-dns"

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
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/nodes.${var.cluster_name}"
        },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "external_dns" {
  count = "${var.external_dns_enabled}"
  name  = "${var.cluster_name}-external-dns"
  role  = "${aws_iam_role.external_dns.id}"

  policy = <<EOF
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
}
