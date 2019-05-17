# Worker node config

variable "node_group_name" {
  default = "eks"
}

variable "default_worker_instance_type" {
  default = "m4.large"
}

variable "spot_nodes_enabled" {
  default = false
}

variable "min_nodes_per_az" {
  default = 1
}

variable "desired_nodes_per_az" {
  default = 1
}

variable "max_nodes_per_az" {
  default = 2
}

variable "max_spot_price" {
  default = "0.40"
}

variable "ami_image_id" {
  description = "Overwrites the default ami (latest Amazon EKS)"
  default     = ""
}

# Data sources

variable "cluster_name" {}

variable "owner" {
  default = "opendatacube.org"
}

variable "region" {

}

