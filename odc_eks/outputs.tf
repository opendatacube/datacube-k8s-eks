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

output "owner" {
  value = var.owner
}

output "namespace" {
  value = var.namespace
}

output "environment" {
  value = var.environment
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

# The length check here is to prevent destroy plans referencing the wildcard_cert[0] value which doesn't exist on destroy
output "certificate_arn" {
  value = (var.create_certificate && (length(aws_acm_certificate.wildcard_cert) > 0)) ? aws_acm_certificate.wildcard_cert[0].arn : null
}

# The length check here is to prevent destroy plans referencing the waf_webacl[0] value which doesn't exist on destroy
output "waf_acl_id" {
  value = (var.waf_enable && (length(aws_wafregional_web_acl.waf_webacl) > 0)) ? aws_wafregional_web_acl.waf_webacl[0].id : null
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "database_subnets" {
  value = module.vpc.database_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_route_table_ids" {
  value = module.vpc.public_route_table_ids
}
