data "aws_caller_identity" "current" {}

# Format our list of users
locals {
  accounts_arn = "${formatlist("arn:aws:iam::${data.aws_caller_identity.current.account_id}:%s", var.users)}"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid = "1"

    actions = ["sts:AssumeRole"]

    # List of users
    principals {
      type        = "AWS"
      identifiers = ["${local.accounts_arn}"]
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
  assume_role_policy   = "${data.aws_iam_policy_document.assume_role.json}"
  max_session_duration = "28800"
}
