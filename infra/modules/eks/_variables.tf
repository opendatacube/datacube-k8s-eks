variable "cluster_name" {
  default = "terraform-eks"
  type    = string
}

variable "cluster_version" {
  type = "string"
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

variable "users" {
  type = list(string)
}

variable "enable_ec2_ssm" {
  default     = true
  description = "Enables the IAM policy required for AWS EC2 System Manager."
}

variable "user_additional_policy" {
  default     = ""
  description = "The additional IAM policy required for EKS user"
  type        = string
}
