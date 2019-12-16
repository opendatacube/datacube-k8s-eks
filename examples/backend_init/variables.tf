variable "region" {
    description = "The AWS region to provision resources too"
    default = "ap-southeast-2"
}

variable "backend_name" {
    description = "The name used for creation of backend resources like the terraform state bucket"
    default = "odc-test"
}

variable "environment" {
    description = "The name of the environment. e.g. dev, stage, prod"
    default = "stage"
}
