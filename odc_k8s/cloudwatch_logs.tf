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

resource "aws_cloudwatch_log_group" "log_group" {
  count             = var.cloudwatch_logs_enabled ? 1 : 0
  name              = (var.cloudwatch_log_group != "") ? var.cloudwatch_log_group : "${var.cluster_name}-logs"
  retention_in_days = var.cloudwatch_log_retention

  tags = {
    cluster = var.cluster_name
    Owner   = var.owner
  }
}

