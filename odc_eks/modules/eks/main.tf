resource "aws_eks_cluster" "eks" {
  name     = var.cluster_id
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  enabled_cluster_log_types = var.enabled_cluster_log_types

  vpc_config {
    security_group_ids = [aws_security_group.eks_cluster.id]
    subnet_ids         = var.eks_subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy,
  ]

  tags = {
    Name        = var.cluster_id
    Cluster     = var.cluster_id
    Owner       = var.owner
    Namespace   = var.namespace
    Environment = var.environment
  }
}

resource "null_resource" "wait_for_cluster" {

  depends_on = [
    aws_eks_cluster.eks,
  ]

  provisioner "local-exec" {
    command     = var.wait_for_cluster_cmd
    interpreter = var.wait_for_cluster_interpreter
    environment = {
      ENDPOINT = aws_eks_cluster.eks.endpoint
    }
  }
}
