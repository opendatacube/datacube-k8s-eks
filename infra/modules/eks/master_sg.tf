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
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  cidr_blocks       = [element(values(var.admin_access_CIDRs), count.index)]
  description       = element(keys(var.admin_access_CIDRs), count.index)
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks-cluster.id
  to_port           = 443
  type              = "ingress"
}

