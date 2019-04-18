variable "cluster_name" {
  default = "terraform-eks"
  type    = "string"
}

variable "admin_access_CIDRs" {
  description = "Locks ssh and api access to these IPs"
  type        = "map"
}

variable "users" {
  type = "list"
}
