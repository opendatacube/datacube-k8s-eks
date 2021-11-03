output "role_name" {
  value = aws_iam_role.service_account_role.name
}

output "role_arn" {
  value = aws_iam_role.service_account_role.arn
}