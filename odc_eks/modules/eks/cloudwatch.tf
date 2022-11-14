resource "aws_cloudwatch_log_group" "eks_logs" {
  count             = (var.enable_custom_cluster_log_group ? 1 : 0)
  name              = "/aws/eks/${var.cluster_id}/cluster"
  retention_in_days = var.log_retention_period

  tags = merge(
    {
      owner       = var.owner
      namespace   = var.namespace
      environment = var.environment
    },
    var.tags
  )
}
