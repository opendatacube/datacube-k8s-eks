variable "region" {
  default = "ap-southeast-2"
}

variable "owner" {
  default     = "Team name"
  description = "Identifies who is responsible for these resources"
}

variable "cluster_name" {
}

variable "users" {
  type = list(string)
  description = "A list of users that will be given access to the cluster"
}

variable "roles" {
  type = map
  description = "A role object that will be assign to the cluster"
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