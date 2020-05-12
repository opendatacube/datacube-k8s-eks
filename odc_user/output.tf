output "id" {
  value     = aws_iam_access_key.user.id
  sensitive = true
}

output "secret" {
  value     = aws_iam_access_key.user.secret
  sensitive = true
}