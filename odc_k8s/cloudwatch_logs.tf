variable "cloudwatch_logs_enabled" {
  default = false
}

variable "cloudwatch_log_group" {
  default     = ""
  description = "The name of cloudwatch log group"
}

variable "cloudwatch_log_retention" {
  default     = 90
  description = "The number of days to keep logs"
}

locals {
  cloudwatch_log_group = (var.cloudwatch_log_group != "") ? var.cloudwatch_log_group : "${var.cluster_id}-logs"
}

resource "aws_cloudwatch_log_group" "log_group" {
  count             = var.cloudwatch_logs_enabled ? 1 : 0
  name              = local.cloudwatch_log_group
  retention_in_days = var.cloudwatch_log_retention

  tags = {
    Name        = local.cloudwatch_log_group
    Cluster     = var.cluster_id
    Owner       = var.owner
    Namespace   = var.namespace
    Environment = var.environment
  }
}

