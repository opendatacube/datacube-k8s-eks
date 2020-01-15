output "userpool" {
  value = (var.cognito_auth_enabled) ? aws_cognito_user_pool.pool[0].name : null
}

output "client_id" {
  value = (var.cognito_auth_enabled)? aws_cognito_user_pool_client.client[0].id : null
  sensitive = true
}

output "client_secret" {
  value = (var.cognito_auth_enabled)? aws_cognito_user_pool_client.client[0].client_secret : null
  sensitive = true
}