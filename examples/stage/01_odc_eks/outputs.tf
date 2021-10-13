output "cluster_id" {
  value = module.odc_eks.cluster_id
}

output "region" {
  value = module.odc_eks.region
}

output "domain_name" {
  value = module.odc_eks.domain_name
}

output "owner" {
  value = module.odc_eks.owner
}

output "namespace" {
  value = module.odc_eks.namespace
}

output "environment" {
  value = module.odc_eks.environment
}

output "db_enabled" {
  value = local.db_enabled
}

output "db_hostname" {
  value = local.db_enabled ? module.db.db_hostname : ""
}

output "db_admin_username" {
  value     = local.db_enabled ? module.db.db_admin_username : ""
  sensitive = true
}

output "db_admin_password" {
  value     = local.db_enabled ? module.db.db_admin_password : ""
  sensitive = true
}

output "db_name" {
  value = local.db_name
}

output "node_role_arn" {
  value = module.odc_eks.node_role_arn
}

output "node_security_group" {
  value = module.odc_eks.node_security_group
}

output "ami_image_id" {
  value = module.odc_eks.ami_image_id
}

output "certificate_arn" {
  value = data.aws_acm_certificate.domain_cert.arn
}

output "waf_acl_id" {
  value = module.odc_eks.waf_acl_id
}

output "cognito_auth_userpool_id" {
  value     = module.cognito_auth.userpool_id
  sensitive = true
}

output "cognito_auth_userpool_arn" {
  value     = module.cognito_auth.userpool_arn
  sensitive = true
}

output "cognito_auth_userpool_domain" {
  value     = module.cognito_auth.userpool_domain
  sensitive = true
}

output "cognito_auth_userpool_jhub_client_id" {
  value     = module.cognito_auth.client_ids["sandbox-client"]
  sensitive = true
}

output "cognito_auth_userpool_jhub_client_secret" {
  value     = module.cognito_auth.client_secrets["sandbox-client"]
  sensitive = true
}

output "cognito_region" {
  value = local.cognito_region
}