variable "cluster_name" {}

variable "domain_name" {
  description = "The domain name to be used by for applications deployed to the cluster and using ingress"
  type        = "string"
}
variable "txt_owner_id" {
  description = "When using the TXT registry, a name that identifies this instance of ExternalDNS"
  default = "AnOwnerId"
}

variable "owner" {}

# Helm Provider
# =============
variable "install_tiller" {
  default = true
  description = "If true, the terraform helm provider will attempt to install Tiller"
}

variable "tiller_service_account" {
  type = "string"
  description = "The service account that tiller will use"
  default = "tiller"
}

variable "region" {

}
