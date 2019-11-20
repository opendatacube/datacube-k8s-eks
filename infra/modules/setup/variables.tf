variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster. Must be derived from the terraform resource creating the EKS cluster."
}

variable "cluster_endpoint" {
  type        = string
  description = "API endpoint of the EKS cluster. Must be derived from the terraform resource creating the EKS cluster."
}

variable "cluster_ca" {
  type        = string
  description = "Certificate of the EKS cluster. Must be derived from the terraform resource creating the EKS cluster."
}

variable "region" {
  type        = string
  description = "Region of the EKS cluster."
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

variable "node_role_arn" {
  type        = string
  description = "ARN of the Node's IAM Role. Must be derived from the terraform resource which creates the role."
}

variable "user_role_arn" {
  type        = string
  description = "ARN of the User's IAM Role. Must be derived from the terraform resource which creates the role."
}

variable "eks_service_user" {
  type        = string
  description = "Service account username"
  default     = ""
}
