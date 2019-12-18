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
- rolearn: $${node_role_arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- rolearn: $${user_role_arn}
  username: cluster-admin
  groups:
    - system:masters
EOF
  vars = {
    node_role_arn   = var.roles["node-role"]
    user_role_arn   = var.roles["user-role"]
  }
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = data.template_file.map_role_config.rendered
    mapUsers = (length(var.users) > 0) ? data.template_file.map_user_config.rendered : null
  }

}

