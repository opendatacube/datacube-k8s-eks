resource "aws_security_group" "eks-cluster" {
  name        = "terraform-eks-eks-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name = "terraform-eks-eks"
  }
}

# Converts admin_access_CIDRs to descriptions / IP CIDRs
resource "aws_security_group_rule" "eks-cluster-ingress-workstation-https" {
  count = length(var.admin_access_CIDRs)
  cidr_blocks       = [element(values(var.admin_access_CIDRs), count.index)]
  description       = element(keys(var.admin_access_CIDRs), count.index)
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks-cluster.id
  to_port           = 443
  type              = "ingress"
}

# Security group - outbound
resource "aws_security_group_rule" "eks-cluster-egress-node" {
  description              = "Allow cluster control pane to communication with worker nodes"
  type                     = "egress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks-cluster.id
  source_security_group_id = aws_security_group.eks-node.id
}
