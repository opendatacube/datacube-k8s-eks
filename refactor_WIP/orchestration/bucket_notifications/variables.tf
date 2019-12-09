 variable "region" {
  default = "ap-southeast-2"
}

variable "bucket" {
  type = "string"
  description = "S3 bucket to add SNS notification to"
}

variable "prefix" {
  description = "prefixes that should be subscribed to"
  default = ""
}

variable "suffix" {
  type = "string"
  description = "suffix of files to subscribe to"
  default = ".yaml"
}

variable "topic_name" {
  type="string"
  description = "name of the topic"
}