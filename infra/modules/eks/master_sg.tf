resource "aws_security_group" "eks-cluster" {
  name        = "terraform-eks-eks-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

