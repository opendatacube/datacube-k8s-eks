locals {
  default_user_config_template = length(var.users) > 0 ? data.template_file.map_user_config.rendered : null
  mapUsers = var.user_config_template != "" ? var.user_config_template : local.default_user_config_template

  default_role_config_template = length(var.node_roles) > 0 ? data.template_file.map_role_config.rendered : null
  mapRoles = var.role_config_template != "" ? var.role_config_template : local.default_role_config_template
}

data "template_file" "map_user_config" {
  template = <<EOF
%{ for user_name, user_arn in var.users ~}
- userarn: ${user_arn}
  username: ${user_name}
  groups:
    - system:masters
%{ endfor ~}
EOF
}

data "template_file" "map_role_config" {
  template = <<EOF
%{ for node_role_name, node_role_arn in var.node_roles ~}
- rolearn: ${node_role_arn}
  username: ${node_role_name}
  groups:
    - system:bootstrappers
    - system:nodes
%{ endfor ~}
%{ for user_role_name, user_role_arn in var.user_roles ~}
- rolearn: ${user_role_arn}
  username: ${user_role_name}
  groups:
    - system:masters
%{ endfor ~}
EOF
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = local.mapRoles
    mapUsers = local.mapUsers
  }

}

