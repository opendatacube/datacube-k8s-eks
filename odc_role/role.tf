data "aws_caller_identity" "current" {
}

resource "aws_iam_role" "role" {
  name  = var.role.name

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

  tags = {
    Name       = var.role.name
    Cluster    = var.cluster_name
    Environment= var.environment
    Owner      = var.owner
    Workspace  = terraform.workspace
    Created_by = "terraform"
  }
}

resource "aws_iam_role_policy" "role_policy" {
  name  = var.role.name
  role  = aws_iam_role.role.id
  policy = var.role.policy
}
