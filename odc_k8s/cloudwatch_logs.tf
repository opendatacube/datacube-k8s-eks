variable "cloudwatch_logs_enabled" {
  default = false
}

variable "cloudwatch_log_group" {
  default     = "datakube"
  description = "the name of your log group, will need to match fluentd config"
}

variable "cloudwatch_log_retention" {
  default     = 90
  description = "The number of days to keep logs"
}

resource "aws_cloudwatch_log_group" "datakube" {
  count             = var.cloudwatch_logs_enabled ? 1 : 0
  name              = "${var.cluster_name}-${var.cloudwatch_log_group}"
  retention_in_days = var.cloudwatch_log_retention

  tags = {
    cluster = var.cluster_name
    Owner   = var.owner
  }
}

