resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks-cluster.arn
  version  = var.cluster_version

  vpc_config {
    security_group_ids = [aws_security_group.eks-cluster.id]
    subnet_ids         = var.eks_subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy,
  ]
}