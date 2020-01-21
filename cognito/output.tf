output "userpool" {
  value = aws_cognito_user_pool.pool.name : null
}

output "userpool_id" {
  value = aws_cognito_user_pool.pool.id : null
  sensitive = true
}

output "userpool_domain" {
  value = aws_cognito_user_pool_domain.domain.domain : null
}

output "client_id" {
  value = aws_cognito_user_pool_client.client.id : null
  sensitive = true
}

output "client_secret" {
  value = aws_cognito_user_pool_client.client.client_secret : null
  sensitive = true
}