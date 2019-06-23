variable "bucket" {
  type        = string
  description = "S3 bucket with SNS topic to subscribe to"
}

variable "services" {
  type        = list(string)
  description = "list of services that will require an SQS queue"
  default     = []
}

variable "region" {
  default = "ap-southeast-2"
}

variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "topic_arn" {
  type        = string
  description = "ARN of SNS topic to subscribe to"
}

