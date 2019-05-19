variable "cluster_name" {}

variable "owner" {}

variable "region" {
  type = "string"
  default = "ap-southeast-2"
}

# Helm Provider
# =============
variable "install_tiller" {
  default = true
  description = "If true, the terraform helm provider will attempt to install Tiller"
}
