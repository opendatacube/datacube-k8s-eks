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

output "db_hostname" {
  value = module.odc_eks.db_hostname
}

output "db_admin_username" {
  value     = module.odc_eks.db_admin_username
  sensitive = true
}

output "db_admin_password" {
  value     = module.odc_eks.db_admin_password
  sensitive = true
}

output "db_name" {
  value = module.odc_eks.db_name
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
  value = (local.create_certificate) ? module.odc_eks.certificate_arn[0] : data.aws_acm_certificate.domain_cert[0].arn
}

output "waf_acl_id" {
  value = module.odc_eks.waf_acl_id
}

output "cognito_auth_userpool_id" {
  value = module.cognito_auth.userpool_id
}

output "cognito_auth_userpool_domain" {
  value = module.cognito_auth.userpool_domain
}

output "cognito_auth_userpool_jhub_client_id" {
  value     = module.cognito_auth.client_ids[0]
  sensitive = true
}

output "cognito_auth_userpool_jhub_client_secret" {
  value     = module.cognito_auth.client_secrets[0]
  sensitive = true
}

output "cognito_auth_userpool_airflow_client_id" {
  value     = module.cognito_auth.client_ids[1]
  sensitive = true
}

output "cognito_auth_userpool_airflow_client_secret" {
  value     = module.cognito_auth.client_secrets[1]
  sensitive = true
}