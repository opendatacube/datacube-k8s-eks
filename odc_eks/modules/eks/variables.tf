variable "cluster_name" {
  default = "terraform-eks"
  type    = string
}

variable "cluster_version" {
  description = "EKS Version to use with this cluster"
}

variable "admin_access_CIDRs" {
  description = "Locks ssh and api access to these IPs"
  type        = map(string)
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to place EKS in"
}

variable "eks_subnet_ids" {
  type        = list(string)
  description = "List of subnets to place EKS workers in"
}

variable "enable_ec2_ssm" {
  default     = true
  description = "Enables the IAM policy required for AWS EC2 System Manager."
}

variable "user_custom_policy" {
  description = "The IAM custom policy to create and attach to EKS user role"
  type        = string
  default     = ""
}

variable "user_additional_policy_arn" {
  description = "The list of pre-defined IAM policy required to EKS user role"
  type        = list(string)
  default     = []
}

# Worker variables
variable "owner" {
}

variable "ami_image_id" {
  default     = ""
  description = "Overwrites the default ami (latest Amazon EKS)"
}

variable "node_group_name" {
  default = "eks"
}

variable "default_worker_instance_type" {
}

variable "min_nodes" {
  default = 0
}

variable "desired_nodes" {
  default = 0
}

variable "max_nodes" {
  default = 0
}

variable "spot_nodes_enabled" {
  default = false
}

variable "min_spot_nodes" {
  default = 0
}

variable "max_spot_nodes" {
  default = 0
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

variable "extra_userdata" {
  type        = string
  description = "Additional EC2 user data commands that will be passed to EKS nodes"
  default     = <<USERDATA
echo ""
USERDATA

}
