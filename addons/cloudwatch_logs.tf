variable "cloudwatch_logs_enabled" {
  default = false
}

variable "cloudwatch_log_group" {
  default     = "datakube"
  description = "the name of your log group, will need to match fluentd config"
}

variable "cloudwatch_log_retention" {
  default     = 90
  description = "The number of days to keep logs"
}

resource "kubernetes_namespace" "fluentd" {
  count = "${var.cloudwatch_logs_enabled ? 1 : 0}"
  metadata {
    name = "fluentd"

    labels {
        managed-by = "Terraform"
    }
  }
}

resource "aws_cloudwatch_log_group" "datakube" {
  count             = "${var.cloudwatch_logs_enabled ? 1 : 0}"
  name              = "${var.cluster_name}-${var.cloudwatch_log_group}"
  retention_in_days = "${var.cloudwatch_log_retention}"

  tags {
    cluster = "${var.cluster_name}"
    Owner   = "${var.owner}"
  }
}

# ======================================
# Fluentd


resource "helm_release" "fluentd-cloudwatch" {
  count      = "${var.cloudwatch_logs_enabled ? 1 : 0}"
  name       = "fluentd-cloudwatch"
  repository = "${data.helm_repository.incubator.metadata.0.name}"
  chart      = "fluentd-cloudwatch"
  namespace  = "fluentd"

  values = [
    "${file("${path.module}/config/fluentd-cloudwatch.yaml")}",
  ]

  set {
    name = "awsRole"
    value = "${aws_iam_role.fluentd.name}"
  }

  set {
    name = "logGroupName"
    value = "${var.cluster_name}"
  }

  set {
    name = "awsRegion"
    value = "${data.aws_region.current.name}"
  }

  # Uses kube2iam for credentials
  depends_on = ["helm_release.kube2iam", "aws_iam_role.fluentd", "aws_iam_role_policy.fluentd", "kubernetes_namespace.fluentd"]
}

resource "aws_iam_role" "fluentd" {
  count = "${var.cloudwatch_logs_enabled ? 1 : 0}"
  name  = "${var.cluster_name}-fluentd"

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

resource "aws_iam_role_policy" "fluentd" {
  count = "${var.cloudwatch_logs_enabled}"
  name  = "${var.cluster_name}-fluentd"
  role  = "${aws_iam_role.fluentd.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    }
  ]
}
EOF
}
