variable "region" {
  description = "The AWS region to provision resources"
  default = "ap-southeast-2"
}

variable "namespace" {
  description = "The name used for creation of backend resources like the terraform state bucket"
  default = "odc-test"
}

variable "owner" {
  description = "The owner of the environment"
  default = "odc-test"
}

variable "environment" {
  description = "The name of the environment - e.g. dev, stage, prod"
  default = "stage"
}

variable "cluster_id" {
  type = string
  description = "The name of your cluster"
}

variable "node_roles" {
  type = map
  description = "A list of node roles that will be given access to the cluster"
}

variable "user_roles" {
  default = {}
  type = map
  description = "A list of user roles that will be given access to the cluster"
}

variable "users" {
  default = {}
  type = map
  description = "A list of users that will be given access to the cluster"
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