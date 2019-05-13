# ======================================
# WMS

resource "aws_iam_role" "wms" {
  count = "${var.datacube_wms_enabled}"
  name  = "${var.cluster_name}-wms"

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

resource "aws_iam_role_policy" "wms" {
  count = "${var.datacube_wms_enabled}"
  name  = "${var.cluster_name}-wms"
  role  = "${aws_iam_role.wms.id}"

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
      "Action": ["s3:*"],
      "Resource": [
        "arn:aws:s3:::datacube-index-dump/*"
      ]
    }
  ]
}
EOF
}
