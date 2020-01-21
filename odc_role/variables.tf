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

variable "role" {
  type        = map
  description = "Provision a role that can be used by pods/applications on the k8s cluster"
}