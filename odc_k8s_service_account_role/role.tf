locals {
  max_session_duration = lookup(var.service_account_role, "max_session_duration", 3600)
}

data "aws_iam_policy_document" "trust_policy" {
  statement {
    sid = "1"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_arn]
    }

    condition {
      test     = (var.service_account_role.service_account_name != "*") ? "StringEquals" : "StringLike"
      variable = "${replace(var.oidc_url, "https://", "")}:sub"
      values = [
        "system:serviceaccount:${var.service_account_role.service_account_namespace}:${var.service_account_role.service_account_name}"
      ]
    }
  }
}

resource "aws_iam_role" "service_account_role" {
  name                 = var.service_account_role.name
  assume_role_policy   = data.aws_iam_policy_document.trust_policy.json
  max_session_duration = local.max_session_duration
  tags = merge(
    {
      name        = var.service_account_role.name
      owner       = var.owner
      namespace   = var.namespace
      environment = var.environment
    },
    var.tags
  )
}

resource "aws_iam_role_policy" "service_account_role_policy" {
  name   = var.service_account_role.name
  role   = aws_iam_role.service_account_role.id
  policy = var.service_account_role.policy
}