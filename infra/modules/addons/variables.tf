variable "cluster_id" {
}

variable "cluster_api_endpoint" {
}

variable "cluster_ca" {
}

variable "cluster_arn" {
}

variable "aws_region" {
}

variable "domain_name" {
  description = "The domain name to be used by for applications deployed to the cluster and using ingress"
  type        = string
}

variable "owner" {
}

variable "external_dns_enabled" {
  default = false
}

variable "txt_owner_id" {
} 

variable "alb_ingress_enabled" {
  default = false
}

variable "cluster_autoscaler_enabled" {
  default = false
}

variable "autoscaler-scale-down-unneeded-time" {
}