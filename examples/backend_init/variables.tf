variable "region" {
    description = "The AWS region to provision resources too"
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
    description = "The name of the environment e.g. dev, stage, prod"
    default = "stage"
}
