output "node_instance_profile" {
  value = aws_iam_instance_profile.eks-node.id
}

output "node_security_group" {
  value = aws_security_group.eks-node.id
}

output "kubeconfig" {
  value = local.kubeconfig
}

output "eks_cluster_version" {
  value = aws_eks_cluster.eks.version
}

output "api_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "cluster_arn" {
  value = aws_eks_cluster.eks.arn
}

output "cluster_ca" {
  value = aws_eks_cluster.eks.certificate_authority[0].data
}

output "node_role_arn" {
  value = aws_iam_role.eks-node.arn
}

output "cluster_id" {
  value = aws_eks_cluster.eks.id
}

output "ami_image_id" {
  value = local.ami_id
}

output "node_asg_names" {
  value = aws_autoscaling_group.nodes.*.name
}

output "spot_node_asg_names" {
  value = aws_autoscaling_group.spot_nodes.*.name
}