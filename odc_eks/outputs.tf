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

output "owner"  {
  value = var.owner
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

output "node_role_arn" {
  value = module.eks.node_role_arn
}


# output "database_credentials" {
  # value = <<EOF
# apiVersion: v1
# kind: Secret
# type: Opaque
# metadata:
  # name: ${var.cluster_name}
  # namespace: default
# data:
  # postgres-username: ${base64encode(module.db.db_admin_username)} 
  # postgres-password: ${base64encode(module.db.db_admin_password)} 
# EOF


#   sensitive = true
# }

data "aws_caller_identity" "current" {
}
