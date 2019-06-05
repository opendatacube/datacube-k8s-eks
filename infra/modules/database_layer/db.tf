#==============================================================
# Database / rds.tf
#==============================================================

# Create a subnet group and rds

resource "aws_db_subnet_group" "default" {
  name       = "${var.cluster}-db"
  subnet_ids = var.database_subnet_group

  tags = {
    Name       = "${var.cluster}-${var.workspace}"
    Cluster    = var.cluster
    Workspace  = var.workspace
    Owner      = var.owner
    Created_by = "terraform"
  }
}

resource "aws_db_instance" "db" {
  count      = var.db_instance_enabled ? 1 : 0
  identifier = "db-${var.cluster}-${var.workspace}"

  # Instance parameters
  allocated_storage      = var.storage
  storage_type           = "gp2"
  instance_class         = var.instance_class
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.default.id

  # DB parameters
  name           = var.db_name
  username       = var.db_username
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
    Name       = "db-${var.cluster}-${var.workspace}"
    Cluster    = var.cluster
    Workspace  = var.workspace
    Owner      = var.owner
    Created_by = "terraform"
  }
}

resource "random_string" "password" {
  length  = 16
  special = false
}

