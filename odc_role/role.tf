data "aws_caller_identity" "current" {
}

data "aws_iam_policy_document" "trust_policy" {
  statement {
    sid = ""
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }

  statement {
    sid = ""
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/nodes.${var.cluster_id}"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role" {
  name               = var.role.name
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json

  tags = merge(
    {
      Name        = var.role.name
      owner       = var.owner
      namespace   = var.namespace
      environment = var.environment
    },
    var.tags
  )
}

resource "aws_iam_role_policy" "role_policy" {
  name   = var.role.name
  role   = aws_iam_role.role.id
  policy = var.role.policy
}
