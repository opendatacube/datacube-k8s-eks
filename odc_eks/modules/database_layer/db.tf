#==============================================================
# Database / rds.tf
#==============================================================

# Create a subnet group and rds

resource "aws_db_subnet_group" "db_sg" {
  name       = "${var.db_label}-db-sg"
  subnet_ids = var.database_subnet_group

  tags = {
    Name        = "${var.db_label}-db"
    Cluster     = var.cluster_id
    Owner       = var.owner
    Namespace   = var.namespace
    Environment = var.environment
  }
}

resource "aws_db_instance" "db" {
  identifier = "db-${var.db_label}"

  # Instance parameters
  allocated_storage      = var.storage
  max_allocated_storage  = var.db_max_storage
  storage_type           = "gp2"
  instance_class         = var.instance_class
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.db_sg.id
  multi_az               = var.rds_is_multi_az

  # DB parameters
  name           = var.db_name
  username       = var.db_admin_username
  password       = random_string.password.result
  engine         = var.engine
  engine_version = var.engine_version[var.engine]

  # only for dev/test builds
  skip_final_snapshot = true

  # Backup / Storage
  backup_window           = var.backup_window
  backup_retention_period = var.backup_retention_period
  storage_encrypted       = var.storage_encrypted

  tags = {
    Name        = "db-${var.db_label}"
    Cluster     = var.cluster_id
    Owner       = var.owner
    Namespace   = var.namespace
    Environment = var.environment
  }
}

resource "random_string" "password" {
  length  = 16
  special = false
}

