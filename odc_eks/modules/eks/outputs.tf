output "node_instance_profile" {
  value = aws_iam_instance_profile.eks_node.id
}

output "cluster_security_group" {
  value = aws_eks_cluster.eks.vpc_config.cluster_security_group_id
}

output "node_security_group" {
  value = aws_security_group.eks_node.id
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
  value = aws_iam_role.eks_node.arn
}

output "cluster_id" {
  description = "The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready"
  value       = aws_eks_cluster.eks.id
  # So that calling plans wait for the cluster to be available before attempting
  # to use it. They will not need to duplicate this null_resource
  depends_on = [null_resource.wait_for_cluster]
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
