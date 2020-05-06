#==============================================================
# Database / rds-sg.tf
#==============================================================

# Security groups for the RDS.

resource "aws_security_group" "rds" {
  name        = "${var.name}-rds-sg"
  description = "allow traffic from the instance sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.db_port_num
    to_port         = var.db_port_num
    protocol        = "tcp"
    security_groups = var.access_security_groups
  }

  tags = merge(
    {
      Name        = "${var.name}-rds-sg"
      owner       = var.owner
      namespace   = var.namespace
      environment = var.environment
    },
    var.tags
  )
}

