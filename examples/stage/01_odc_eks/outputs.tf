output "cluster_id" {
  value = module.odc_eks.cluster_id
}

output "region" {
  value = module.odc_eks.region
}

output "domain_name" {
  value = module.odc_eks.domain_name
}

output "owner"  {
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
  value = module.odc_eks.db_admin_username
  sensitive = true
}

output "db_admin_password" {
  value = module.odc_eks.db_admin_password
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