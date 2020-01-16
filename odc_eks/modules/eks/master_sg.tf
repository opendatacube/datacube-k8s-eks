resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.cluster_name}-cluster-sg"
    Cluster     = var.cluster_name
    Owner       = var.owner
    Namespace   = var.namespace
    Environment = var.environment
  }
}

# Converts admin_access_CIDRs to descriptions / IP CIDRs
resource "aws_security_group_rule" "eks-cluster-ingress-workstation-https" {
  count = length(var.admin_access_CIDRs)
  cidr_blocks       = [element(values(var.admin_access_CIDRs), count.index)]
  description       = element(keys(var.admin_access_CIDRs), count.index)
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_cluster.id
  to_port           = 443
  type              = "ingress"
}

