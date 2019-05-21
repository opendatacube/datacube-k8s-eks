variable "cluster_name" {}

variable "ami_image_id" {
  default = ""
}

variable "owner" {
  default     = "Team name"
  description = "Identifies who is responsible for these resources"
}

variable "default_worker_instance_type" {
  default = "m4.large"
}

variable "node_group_name" {
  default = "eks"
}

variable "nodes_subnet_group" {
  type = "list"
}

variable "node_instance_profile" {}

variable "eks_cluster_version" {}

variable "node_security_group" {}

variable "api_endpoint" {}

variable "cluster_ca" {}

# Node Config
variable "nodes_enabled" {
  default = false
}

variable "min_nodes" {
  default = 1
}

variable "desired_nodes" {
  default = 1
}

variable "max_nodes" {
  default = 2
}

# Spot Config
variable "spot_nodes_enabled" {
  default = false
}

variable "max_spot_price" {
  default = "0.40"
}
