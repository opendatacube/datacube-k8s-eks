resource "aws_security_group" "eks_lb" {
  name        = "${var.cluster_name}-lb-sg"
  description = "Security group for eks load balancers"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.cluster_name}-lb-sg"
    Cluster     = var.cluster_name
    Owner       = var.owner
    Namespace   = var.namespace
    Environment = var.environment
  }
}