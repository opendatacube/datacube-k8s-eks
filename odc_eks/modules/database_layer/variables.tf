#==============================================================
# Database / variables.tf
#==============================================================

variable "db_label" {
  description = "Label prefix use by resources"
  type        = string
}

#--------------------------------------------------------------
# Network
#--------------------------------------------------------------

variable "database_subnet_group" {
  description = "Subnet group for the database"
  type        = list(string)
}

variable "access_security_groups" {
  type = list(string)
}

variable "vpc_id" {
}

#--------------------------------------------------------------
# Database
#--------------------------------------------------------------

variable "identifier" {
  default     = "mydb-rds"
  description = "Identifier for your DB"
}

variable "storage" {
  default     = "180"
  description = "Storage size in GB"
}

variable "db_max_storage" {
  default     = "0"
  description = "Enables storage autoscaling up to this amount, disabled if 0"
}

variable "engine" {
  default     = "postgres"
  description = "Engine type: e.g. mysql, postgres"
}

variable "engine_version" {
  description = "Engine version"

  default = {
    postgres = "9.6.11"
  }
}

variable "instance_class" {
  default     = "db.m4.xlarge"
  description = "aws instance"
}

variable "db_name" {
  default     = "mydb"
  description = "Name of the first db"
}

variable "db_admin_username" {
  default = "superuser"
}

variable "rds_is_multi_az" {
  default = false
}

variable "backup_retention_period" {
  # Days
  default = "30"
}

variable "backup_window" {
  # 12:00AM-03:00AM AEST
  default = "14:00-17:00"
}

variable "storage_encrypted" {
  default = true
}

variable "db_port_num" {
  default     = "5432"
  description = "Default port for database"
}

variable "extra_sg" {
  default = ""
}

variable "snapshot_identifier" {
  default = ""
  type = string
  # via TF. docs Specifies whether or not to create this database from a snapshot. This correlates to the
  # snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05.
  description = "Snapshot ID for database creation if a migration is being performed to deploy new infrastructure\nwith pre-existing data indexed. This variable can be used to point to Snapshot ID and perform a restore on create\nfor the new RDS instance. This variable is optional."
}

#--------------------------------------------------------------
# Tags
#--------------------------------------------------------------
variable "cluster_id" {
}

variable "environment" {
}

variable "namespace" {
}

variable "owner" {
}

