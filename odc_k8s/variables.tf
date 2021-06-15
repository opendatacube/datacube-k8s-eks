variable "region" {
  description = "The AWS region to provision resources"
  type        = string
}

variable "namespace" {
  description = "The unique namespace for the environment, which could be your organization name or abbreviation"
  type        = string
}

variable "owner" {
  description = "The owner of the environment"
  type        = string
}

variable "environment" {
  description = "The name of the environment - e.g. dev, stage, prod"
  type        = string
}

variable "cluster_id" {
  type        = string
  description = "The name of your cluster. Also used on all the resources as identifier"
}

variable "node_roles" {
  default     = {}
  type        = map(any)
  description = "A list of node roles that will be given access to the cluster"
}

variable "user_roles" {
  default     = {}
  type        = map(any)
  description = "A list of user roles that will be given access to the cluster"
}

variable "users" {
  default     = {}
  type        = map(any)
  description = "A list of users that will be given access to the cluster"
}

variable "role_config_template" {
  default     = ""
  type        = string
  description = "aws-auth MapRoles config template"
}

variable "user_config_template" {
  default     = ""
  type        = string
  description = "aws-auth MapUsers config template"
}

variable "db_hostname" {
  type        = string
  description = "DB hostname for coredns config"
  default     = ""
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
  type        = bool
}

variable "tags" {
  type        = map(string)
  description = "Additional tags (e.g. `map('StackName','XYZ')`)"
  default     = {}
}