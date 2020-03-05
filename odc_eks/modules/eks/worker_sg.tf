resource "aws_security_group" "eks_node" {
  name        = "${var.cluster_id}-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.cluster_id}-node-sg"
      owner = var.owner
      namespace = var.namespace
      environment = var.environment
    },
    var.tags
  )
}

resource "aws_security_group_rule" "eks_node_ingress_self" {
  description              = "Allow worker nodes to communicate with each other"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_node.id
  source_security_group_id = aws_security_group.eks_node.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_node_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_node.id
  source_security_group_id = aws_security_group.eks_cluster.id
  type                     = "ingress"
}

# for api metrics
resource "aws_security_group_rule" "eks_node_ingress_cluster_https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_node.id
  source_security_group_id = aws_security_group.eks_cluster.id
  type                     = "ingress"
}

# Connects workers to load balancers
resource "aws_security_group_rule" "eks_node_ingress_lb_http" {
  description              = "Allow worker pods to receive communication from the load balancers over http"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_node.id
  source_security_group_id = aws_security_group.eks_lb.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_node_ingress_lb_https" {
  description              = "Allow worker pods to receive communication from the load balancers over https"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_node.id
  source_security_group_id = aws_security_group.eks_lb.id
  type                     = "ingress"
}