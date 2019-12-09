variable "cluster_name" {
}

variable "ami_image_id" {
  default = ""
}

variable "owner" {
}

variable "default_worker_instance_type" {
}

variable "node_group_name" {
  default = "eks"
}

variable "nodes_subnet_group" {
  type = list(string)
}

variable "node_instance_profile" {
}

variable "eks_cluster_version" {
}

variable "node_security_group" {
}

variable "api_endpoint" {
}

variable "cluster_ca" {
}

# Node Config
variable "min_nodes" {
  default = 1
}

variable "desired_nodes" {
  default = 1
}

variable "max_nodes" {
  default = 2
}

variable "min_spot_nodes" {
  default = 0
}

variable "max_spot_nodes" {
  default = 2
}

variable "volume_size" {
  default = 20
}

variable "spot_volume_size" {
  default = 20
}

# Spot Config
variable "spot_nodes_enabled" {
  default = false
}

variable "max_spot_price" {
  default = "0.40"
}

variable "extra_userdata" {
  type        = string
  description = "Additional EC2 user data commands that will be passed to EKS nodes"
  default     = <<USERDATA
echo ""
USERDATA

}

