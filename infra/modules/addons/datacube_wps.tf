# ======================================
# WPS

variable "datacube_wps_enabled" {
  default = false
}

resource "aws_iam_role" "wps" {
  count = "${var.datacube_wps_enabled}"
  name  = "eks-wps"

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

resource "aws_iam_role_policy" "wps" {
  count = "${var.datacube_wps_enabled}"
  name  = "wps"
  role  = "${aws_iam_role.wps.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["S3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::dea-public-data"
      ]
    },
    {
      "Effect": "Allow",
      "Action": ["S3:GetObject"],
      "Resource": [
        "arn:aws:s3:::dea-public-data/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObjectAcl",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::dea-wps-results",
        "arn:aws:s3:::dea-wps-results/*"
      ]
    }
  ]
}
EOF
}
