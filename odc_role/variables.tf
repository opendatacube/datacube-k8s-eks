variable "namespace" {
  description = "The unique namespace for the environment, which could be your organization name or abbreviation"
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
  description = "The name of your cluster for role based cluster access - attach to assume role policy"
}

variable "role" {
  type        = map
  description = "Provision a role that can be used by pods/applications on the k8s cluster"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags (e.g. `map('StackName','XYZ')`)"
  default     = {}
}