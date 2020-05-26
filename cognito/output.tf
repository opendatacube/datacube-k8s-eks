output "userpool_id" {
  value     = aws_cognito_user_pool.pool.id
  sensitive = true
}

output "userpool_domain" {
  value = aws_cognito_user_pool_domain.domain.domain
}

output "client_ids" {
  value = {
    for client in aws_cognito_user_pool_client.clients :
    client.name => client.id
  }
  sensitive = true
}

output "client_secrets" {
  value = {
    for client in aws_cognito_user_pool_client.clients :
    client.name => client.client_secret
  }
  sensitive = true
}