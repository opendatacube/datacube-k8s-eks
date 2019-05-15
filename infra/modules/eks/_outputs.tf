locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.eks-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: ${aws_iam_role.eks-user.arn}
      username: cluster-admin
      groups:
        - system:masters
CONFIGMAPAWSAUTH
}

output "config_map_aws_auth" {
  value = "${local.config_map_aws_auth}"
}

output "node_instance_profile" {
  value = "${aws_iam_instance_profile.eks-node.id}"
}

output "node_security_group" {
  value = "${aws_security_group.eks-node.id}"
}

# output "nodes_subnet_group" {
#   value = "${aws_subnet.eks.*.id}"
# }

# output "database_subnet_group" {
#   value = "${aws_subnet.db.*.id}"
# }

# output "vpc_id" {
#   value = "${aws_vpc.eks.id}"
# }

output "kubeconfig" {
  value = "${local.kubeconfig}"
}

output "eks_cluster_version" {
  value = "${aws_eks_cluster.eks.version}"
}

output "api_endpoint" {
  value = "${aws_eks_cluster.eks.endpoint}"
}

output "cluster_ca" {
  value = "${aws_eks_cluster.eks.certificate_authority.0.data}"
}

output "user_role_arn" {
  value = "${aws_iam_role.eks-user.arn}"
}
