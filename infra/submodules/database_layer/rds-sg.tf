#==============================================================
# Database / rds-sg.tf
#==============================================================

# Security groups for the RDS.

resource "aws_security_group" "rds" {
  name        = "${var.cluster}_${var.workspace}_ecs_rds_sg"
  description = "allow traffic from the instance sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.db_port_num
    to_port         = var.db_port_num
    protocol        = "tcp"
    security_groups = var.access_security_groups
  }

  tags = {
    Name       = "ecs-rds-sg"
    Cluster    = var.cluster
    Workspace  = var.workspace
    Owner      = var.owner
    Created_by = "terraform"
  }
}

