output "oidc_arn" {
  value = aws_iam_openid_connect_provider.identity_provider.arn
}

output "oidc_url" {
  value = aws_iam_openid_connect_provider.identity_provider.url
}