variable "cluster_name" {
  default = "terraform-eks"
  type    = "string"
}

variable "admin_access_CIDRs" {
  description = "Locks ssh and api access to these IPs"
  type        = "map"
}

variable "vpc_id" {
  type = "string"
  description = "ID of the VPC to place EKS in"
}

variable "eks_subnet_ids" {
  type = "list"
  description = "List of subnets to place EKS workers in"
}

variable "users" {
  type = "list"
}
