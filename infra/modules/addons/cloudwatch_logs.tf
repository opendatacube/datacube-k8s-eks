variable "cloudwatch_logs_enabled" {
  default = false
}

variable "cw_log_group" {
  default = "datacube"
}

variable "cw_log_retention" {
  default = 90
}

resource "aws_cloudwatch_log_group" "datakube" {
  count             = "${var.cloudwatch_logs_enabled}"
  name              = "${var.cluster_name}-${var.cw_log_group}"
  retention_in_days = "${var.cw_log_retention}"

  tags {
    cluster = "${var.cluster_name}"
    Owner   = "${var.owner}"
  }
}

# ======================================
# Fluentd
resource "aws_iam_role" "fluentd" {
  count = "${var.cloudwatch_logs_enabled}"
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
