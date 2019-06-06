variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster. Must be derived from the terraform resource creating the EKS cluster."
}

variable "region" {
  type        = string
  description = "Region of the EKS cluster."
}

variable "db_username" {
  type        = string
  description = "Username for the database to store in a default kubernetes secret"
  default     = ""
}

variable "db_password" {
  type        = string
  description = "Password for the database to store in a default kubernetes secret"
  default     = ""
}

variable "store_db_creds" {
  default     = false
  description = "If true, store the db_username and db_password variables in a kubernetes secret"
}

variable "node_role_arn" {
  type        = string
  description = "ARN of the Node's IAM Role. Must be derived from the terraform resource which creates the role."
}

variable "user_role_arn" {
  type        = string
  description = "ARN of the User's IAM Role. Must be derived from the terraform resource which creates the role."
}

