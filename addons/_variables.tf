variable "cluster_name" {}

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
