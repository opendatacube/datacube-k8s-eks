data "aws_iam_user" "service_user" {
  count  = (var.eks_service_user != "") ? 1 : 0
  user_name = var.eks_service_user
}

data "template_file" "map_user_config" {
  count  = (var.eks_service_user != "") ? 1 : 0
  template = <<EOF
- userarn: $${eks_service_user_arn}
  username: $${eks_service_user}
  groups:
    - system:masters
EOF
  vars = {
    eks_service_user     = "${var.eks_service_user}"
    eks_service_user_arn = "${data.aws_iam_user.service_user[0].arn}"
  }
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  # data {
  #   mapRoles = "- rolearn: ${var.node_role_arn}\n  username: system:node:{{EC2PrivateDNSName}}\n  groups:\n    - system:bootstrappers\n    - system:nodes\n- rolearn: ${var.user_role_arn}\n  username: cluster-admin\n  groups:\n    - system:masters\n"
  # }

  data = {
    mapRoles = <<EOF
- rolearn: ${var.node_role_arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- rolearn: ${var.user_role_arn}
  username: cluster-admin
  groups:
    - system:masters
EOF
    mapUsers = (var.eks_service_user != "") ? data.template_file.map_user_config[0].rendered : null
  }

}

