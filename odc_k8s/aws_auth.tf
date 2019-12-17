locals {
  users = formatlist(
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:%s",
    var.users
  )
}

data "template_file" "map_user_config" {
  count    = length(local.users)
  template = <<EOF
- userarn: $${user_arn}
  username: $${user_name}
  groups:
    - system:masters
EOF
  vars = {
    user_name = element(split("/",local.users[count.index]), 1)
    user_arn  = local.users[count.index]
  }
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
    mapUsers = (length(local.users) > 0) ? data.template_file.map_user_config[0].rendered : null
  }

}

