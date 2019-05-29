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
      # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
      # force an interpolation expression to be interpreted as a list by wrapping it
      # in an extra set of list brackets. That form was supported for compatibilty in
      # v0.11, but is no longer supported in Terraform v0.12.
      #
      # If the expression in the following list itself returns a list, remove the
      # brackets to avoid interpretation as a list of lists. If the expression
      # returns a single list item then leave it as-is and remove this TODO comment.
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
  name        = "user-policy"
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
