resource "aws_eks_cluster" "eks" {
  name     = var.cluster_id
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  vpc_config {
    security_group_ids = [aws_security_group.eks_cluster.id]
    subnet_ids         = var.eks_subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy,
  ]

  tags = merge(
    {
      Name        = var.cluster_id
      cluster     = var.cluster_id
      owner       = var.owner
      namespace   = var.namespace
      environment = var.environment
    },
    var.tags
  )
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