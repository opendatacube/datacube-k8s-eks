
output "userpool_id" {
  value = aws_cognito_user_pool.pool.id
  sensitive = true
}

output "userpool_domain" {
  value = aws_cognito_user_pool_domain.domain.domain
}

# TODO: remove me! - This is deprecated.
output "client_id" {
  value = (length(var.app_clients) == 0)? aws_cognito_user_pool_client.client[0].id : null
  sensitive = true
}

# TODO: remove me! - This is deprecated.
output "client_secret" {
  value = (length(var.app_clients) == 0)? aws_cognito_user_pool_client.client[0].client_secret : null
  sensitive = true
}

output "client_ids" {
  value = (length(var.app_clients) > 0) ? aws_cognito_user_pool_client.clients.*.id : null
  sensitive = true
}

output "client_secrets" {
  value = (length(var.app_clients) > 0) ? aws_cognito_user_pool_client.clients.*.client_secret : null
  sensitive = true
}