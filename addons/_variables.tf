variable "cluster_name" {}

variable "owner" {}

variable "region" {
  type = "string"
}

# Helm Provider
# =============
variable "install_tiller" {
  default = true
  description = "If true, the terraform helm provider will attempt to install Tiller"
}
