resource "aws_iam_user" "user" {
  name = var.user.name
  path = "/"

  tags = merge(
    {
      Name = var.user.name
      owner = var.owner
      namespace = var.namespace
      environment = var.environment
    },
    var.tags
  )
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy" "jhub_user_ro" {
  name = "${var.user.name}-policy"
  user = aws_iam_user.user.name
  policy = var.user.policy
}