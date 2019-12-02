data "aws_caller_identity" "current" {
}

# Format our list of users
locals {
  accounts_arn = formatlist(
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:%s",
    var.users,
  )
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid = "1"

    actions = ["sts:AssumeRole"]

    # List of users
    principals {
      type = "AWS"
      identifiers = local.accounts_arn
    }

    # Enforce MFA
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role" "eks-user" {
  name                 = "user.${var.cluster_name}"
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
  max_session_duration = "28800"
}


resource "aws_iam_policy" "user_policy" {
  name        = "user-policy.${var.cluster_name}"
  description = "Enables EKS users to get the kubeconfig file using aws cli"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "eks:DescribeCluster"
      ],
      "Effect": "Allow",
      "Resource": "${aws_eks_cluster.eks.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "user_policy_attach" {
  role       = aws_iam_role.eks-user.name
  policy_arn = aws_iam_policy.user_policy.arn
}

resource "aws_iam_policy" "user_additional_policy" {
  count       = (var.user_additional_policy != "") ? 1 : 0
  name        = "user-additional-policy"
  description = "Enables EKS users to have additional policy"
  policy      = var.user_additional_policy
}

resource "aws_iam_role_policy_attachment" "user_additional_policy_attach" {
  count       = (var.user_additional_policy != "") ? 1 : 0
  role       = aws_iam_role.eks-user.name
  policy_arn = aws_iam_policy.user_additional_policy.arn
}