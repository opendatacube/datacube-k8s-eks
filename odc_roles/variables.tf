variable "owner" {
}

variable "namespace" {
  type        = string
  description = "Namespace for your deployment"
}

variable "environment" {
  type        = string
  description = "Name of your environment e.g. dev, stage, prod"
}

variable "roles" {
  type        = list
  description = "list of roles that can be used by pods/applications on the k8s cluster"
  default     = []
}