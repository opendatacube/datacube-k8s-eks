output "userpool" {
  value = aws_cognito_user_pool.pool[0].name : null
}

output "userpool_id" {
  value = aws_cognito_user_pool.pool[0].id : null
  sensitive = true
}

output "userpool_domain" {
  value = aws_cognito_user_pool_domain.domain[0].domain : null
}

output "client_id" {
  value = aws_cognito_user_pool_client.client[0].id : null
  sensitive = true
}

output "client_secret" {
  value = aws_cognito_user_pool_client.client[0].client_secret : null
  sensitive = true
}