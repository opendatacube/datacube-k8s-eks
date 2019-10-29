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
