variable "cluster_name" {
}

variable "domain_name" {
  description = "The domain name to be used by for applications deployed to the cluster and using ingress"
  type        = string
}

variable "txt_owner_id" {
  description = "When using the TXT registry, a name that identifies this instance of ExternalDNS"
  default     = "AnOwnerId"
}

variable "owner" {
}

variable "region" {
  type = string
}

variable "autoscaler-scale-down-unneeded-time" {
  default = "10m"
}

variable "waf_environment" {
  description = "The WAF environment name - used as part of resource name"
  type        = string
}

variable "waf_log_bucket" {
  default     = ""
  description = "The name of the bucket to store waf logs in"
}

variable "waf_firehose_buffer_size" {
  type        = "string"
  description = "Buffer incoming data to the specified size, in MBs, before delivering it to the destination. Valid value is between 64-128. Recommended is 128, specifying a smaller buffer size can result in the delivery of very small S3 objects, which are less efficient to query."
  default     = "128"
}

variable "waf_firehose_buffer_interval" {
  type        = "string"
  description = "Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination. Valid value is between 60-900. Smaller value makes the logs delivered faster. Bigger value increase the chance to make the file size bigger, which are more efficient to query."
  default     = "900"
}
