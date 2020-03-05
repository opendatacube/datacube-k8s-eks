resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_id}-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name = "${var.cluster_id}-cluster-sg"
      owner = var.owner
      namespace = var.namespace
      environment = var.environment
    },
    var.tags
  )
}

resource "aws_security_group_rule" "eks_cluster_ingress_node_https" {
  description              = "Allow worker nodes to communicate with control pane over https"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_node.id
}

# Converts admin_access_CIDRs to descriptions / IP CIDRs
resource "aws_security_group_rule" "eks_cluster_ingress_workstation_https" {
  count             = length(var.admin_access_CIDRs)
  description       = element(keys(var.admin_access_CIDRs), count.index)
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_cluster.id
  cidr_blocks       = [element(values(var.admin_access_CIDRs), count.index)]
}

# Security group - outbound
# Refernce: https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
resource "aws_security_group_rule" "eks_cluster_egress_node" {
  description              = "Allow cluster control pane to communicate with worker nodes"
  type                     = "egress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_node.id
}
