variable "bucket" {
  type = "string"
  description = "S3 bucket to add SNS notification to"
}

variable "services" {
  type = "list"
  description = "list of services that will require an SQS queue"
  default = []
}

 variable "region" {
  default = "ap-southeast-2"
}

variable "name" {
  description = "DNS name of the cluster"
  type = "string"
}

variable "topic_arn" {
  type = "string"
  description = "ARN of SNS topic to subscribe to"
}