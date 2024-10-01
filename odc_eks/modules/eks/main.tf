resource "aws_eks_cluster" "eks" {
  name     = var.cluster_id
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  enabled_cluster_log_types = var.enabled_cluster_log_types

  vpc_config {
    security_group_ids = [aws_security_group.eks_cluster.id]
    subnet_ids         = var.eks_subnet_ids
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy,
    aws_cloudwatch_log_group.eks_logs
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

  lifecycle {
    ignore_changes = [
      # When the access_config was added recently it defaulted to false but didn't affect the cluster setting.
      # Changing this from false to true will cause and existing cluster to be recreated so let's ignore this change to avoid that.
      access_config[0].bootstrap_cluster_creator_admin_permissions,
    ]
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
