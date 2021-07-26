variable "region" {
  description = "The AWS region to provision resources"
  type        = string
  default     = "ap-southeast-2"
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
  default     = ""
}

variable "cluster_version" {
  description = "EKS Cluster version to use"
  type        = string
}

variable "admin_access_CIDRs" {
  description = "Locks ssh and api access to these IPs"
  type        = map(string)

  # No admin access
  default = {}
}

variable "user_custom_policy" {
  description = "The IAM custom policy to create and attach to EKS user role"
  type        = string
  default     = ""
}

variable "user_additional_policy_arn" {
  description = "The list of pre-defined IAM policy required to EKS user role"
  type        = list(string)
  default     = []
}

variable "domain_name" {
  description = "The domain name to be used by for applications deployed to the cluster and using ingress"
  type        = string
}

variable "create_certificate" {
  description = "Whether to create certificate for given domain"
  type        = bool
  default     = false
}

# VPC & subnets
# =================
variable "create_vpc" {
  type        = bool
  description = "Whether to create the VPC and subnets or to supply them. If supplied then subnets and tagging must be configured correctly for AWS EKS use - see AWS EKS VPC requirments documentation"
  default = true
}
## Create VPC = false
variable "vpc_id" {
  type = string
  description = "VPC ID to use if create_vpc = false"
  default = ""
}

variable "private_subnets" {
  type = list(string)
  description = "list of private subnets to use if create_vpc = false"
  default = []
}

variable "database_subnets" {
  type = list(string)
  description = "list of database subnets to use if create_vpc = false"
  default = []
}

variable "public_route_table_ids" {
  type = string
  description = "Will just pass through to outputs if use create_vpc = false. For backwards compatibility."
  default = ""
}

## Create VPC = true
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public cidrs, for all available availability zones. Example: 10.0.0.0/24 and 10.0.1.0/24"
  type        = list(string)
  default = []
}

variable "private_subnet_cidrs" {
  description = "List of private cidrs, for all available availability zones. Example: 10.0.0.0/24 and 10.0.1.0/24"
  type        = list(string)
  default = []
}

variable "database_subnet_cidrs" {
  description = "List of database cidrs, for all available availability zones. Example: 10.0.0.0/24 and 10.0.1.0/24"
  type        = list(string)
  default = []
}

variable "enable_s3_endpoint" {
  type        = bool
  description = "Whether to provision an S3 endpoint to the VPC. Default is set to 'true'"
  default     = true
}

# EC2 Worker Roles
# ==================
variable "enable_ec2_ssm" {
  default     = true
  description = "Enables the IAM policy required for AWS EC2 System Manager in the EKS node IAM role created."
}

# Node configuration
# ===================
variable "ami_image_id" {
  default     = ""
  description = "Overwrites the default ami (latest Amazon EKS)"
}

variable "node_group_name" {
  default = "eks"
}

variable "default_worker_instance_type" {
}

variable "min_nodes" {
  default = 0
}

variable "desired_nodes" {
  default = 0
}

variable "max_nodes" {
  default = 0
}

variable "spot_nodes_enabled" {
  default = false
}

variable "min_spot_nodes" {
  default = 0
}

variable "max_spot_nodes" {
  default = 0
}

variable "max_spot_price" {
  default = "0.40"
  type    = string
}

variable "volume_size" {
  default = 20
  type    = number
}

variable "spot_volume_size" {
  default = 20
  type    = number
}

variable "extra_kubelet_args" {
  type        = string
  description = "Additional kubelet command-line arguments (e.g. '--arg1=value --arg2')"
  default     = ""
}

variable "extra_userdata" {
  type        = string
  description = "Additional EC2 user data commands that will be passed to EKS nodes"
  default     = <<USERDATA
echo ""
USERDATA

}

variable "tags" {
  type        = map(string)
  description = "Additional tags(e.g. `map('StackName','XYZ')`"
  default     = {}
}

variable "node_extra_tags" {
  type        = map(string)
  description = "Additional tags for EKS nodes (e.g. `map('StackName','XYZ')`"
  default     = {}
}
