variable "cluster_id" {
}

variable "cluster_api_endpoint" {
}

variable "cluster_ca" {
}

variable "cluster_arn" {
}

variable "domain_name" {
  description = "The domain name to be used by for applications deployed to the cluster and using ingress"
  type        = string
}

variable "txt_owner_id" {
  description = "When using the TXT registry, a name that identifies this instance of ExternalDNS"
}

variable "owner" {
}

variable "autoscaler-scale-down-unneeded-time" {
}
