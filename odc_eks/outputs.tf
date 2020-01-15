output "kubeconfig" {
  value     = module.eks.kubeconfig
  sensitive = true
}

output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "region" {
  value = var.region
}

output "domain_name" {
  value = var.domain_name
}

output "owner"  {
  value = var.owner
}

output "namespace"  {
  value = var.namespace
}

output "environment"  {
  value = var.environment
}

output "db_hostname" {
  value = module.db.db_hostname
}

output "db_admin_username" {
  value = module.db.db_admin_username
  sensitive = true
}

output "db_admin_password" {
  value = module.db.db_admin_password
  sensitive = true
}

output "db_name" {
  value = var.db_name
}

output "node_role_arn" {
  value = module.eks.node_role_arn
}

output "node_security_group" {
  value = module.eks.node_security_group
}

output "ami_image_id" {
  value = module.eks.ami_image_id
}

data "aws_caller_identity" "current" {
}

output "certificate_arn" {
  value = (var.create_certificate)? aws_acm_certificate.wildcard_cert[0].arn : null
}

output "jhub_userpool" {
  value = module.jhub_cognito_auth.userpool
}

output "jhub_userpool_id" {
  value = module.jhub_cognito_auth.userpool_id
  sensitive = true
}

output "jhub_userpool_domain" {
  value = module.jhub_cognito_auth.userpool_domain
}

output "jhub_auth_client_id" {
  value = module.jhub_cognito_auth.client_id
  sensitive = true
}

output "jhub_auth_client_secret" {
  value = module.jhub_cognito_auth.client_secret
  sensitive = true
}