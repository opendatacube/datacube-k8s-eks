# Worker node config

variable "ami_image_id" {
  default     = ""
  description = "Overwrites the default ami (latest Amazon EKS)"
}

variable "node_group_name" {
  default = "eks"
}

variable "default_worker_instance_type" {
}

variable "group_enabled" {
  default = false
}

variable "spot_nodes_enabled" {
  default = false
}
variable "min_nodes" {
  default = {
    az1 = 0
    az2 = 0
    az3 = 0
  }
}

variable "desired_nodes" {
  default = {
    az1 = 0
    az2 = 0
    az3 = 0
  }
}

variable "max_nodes" {
  default = {
    az0 = 0
    az1 = 0
    az2 = 0
  }
}

variable "min_spot_nodes" {
  default = {
    az0 = 0
    az1 = 0
    az2 = 0
  }
}

variable "max_spot_nodes" {
  default = {
    az0 = 0
    az1 = 0
    az2 = 0
  }
}

# nodes per az variables still work but are deprecated
variable "min_nodes_per_az" {
  default = 1
}

variable "desired_nodes_per_az" {
  default = 1
}

variable "max_nodes_per_az" {
  default = 2
}

variable "min_spot_nodes_per_az" {
  default = 0
}

variable "max_spot_nodes_per_az" {
  default = 2
}

variable "max_spot_price" {
  default = "0.40"
}

variable "volume_size" {
  default = 20
}

variable "spot_volume_size" {
  default = 20
}

variable "cluster_name" {
}

variable "owner" {
  default = "opendatacube.org"
}

variable "region" {
}

variable "extra_userdata" {
  type        = string
  description = "Additional EC2 user data commands that will be passed to EKS nodes"
  default     = <<USERDATA
echo ""
USERDATA

}

