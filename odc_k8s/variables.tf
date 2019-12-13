variable "region" {
  default = "ap-southeast-2"
}

variable "owner" {
  default     = "Team name"
  description = "Identifies who is responsible for these resources"
}

variable "cluster_name" {
  default = "datacube-eks"
}

variable "db_hostname" {
  type = string
  description = "DB hostname for coredns config"
  default = ""
}

variable "db_admin_username" {
  type        = string
  description = "Username for the database to store in a default kubernetes secret"
  default     = ""
}

variable "db_admin_password" {
  type        = string
  description = "Password for the database to store in a default kubernetes secret"
  default     = ""
}

variable "store_db_creds" {
  default     = false
  description = "If true, store the db_admin_username and db_admin_password variables in a kubernetes secret"
}

variable "eks_service_user" {
  type        = string
  description = "EKS Service account IAM user to manage kubernetes cluster. This will update kube-system aws-auth config mapUsers attribute if provided."
}