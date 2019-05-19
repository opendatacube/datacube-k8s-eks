resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data {
    mapRoles = "- rolearn: ${var.node_role_arn}\n  username: system:node:{{EC2PrivateDNSName}}\n  groups:\n    - system:bootstrappers\n    - system:nodes\n- rolearn: ${var.user_role_arn}\n  username: cluster-admin\n  groups:\n    - system:masters\n"
  }
}