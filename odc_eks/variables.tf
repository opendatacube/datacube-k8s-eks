variable "region" {
}

variable "owner" {
  description = "Identifies who is responsible for these resources"
}

variable "namespace" {
  description = "Namespace for your deployment. Use as part of resource naming"
}

variable "environment" {
  description = "Name of your environment. Use as part of resource naming. e.g. dev, stage, prod"
}

variable "cluster_version" {
  description = "EKS Cluster version to use"
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

variable "app_name" {
  description = "The app name to be used by for applications deployed to the cluster and using ingress"
  type        = string
}


variable "create_certificate" {
  description = "Whether to create certificate for given domain"
  type        = string
  default     = false
}

# Database
# ================
variable "db_name" {
}

variable "db_multi_az" {
  default = false
}

variable "db_storage" {
  default     = "180"
  description = "Storage size in GB"
}

variable "db_max_storage" {
  default     = "0"
  description = "Enables storage autoscaling up to this amount, disabled if 0"
}

variable "db_extra_sg" {
  default     = ""
  description = "enables an extra security group to access the RDS"
}

variable "db_engine_version" {
  default = {
    postgres = "9.6.11"
  }
  description = "PostgreSQL engine version used for initialization in specific deployments"
}


# VPC & subnets
# =================
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# TODO Cloud posse have an terraform method for calculating the subnet ids. Might make life easier.
# TODO default CIDRS assume 3 availability zones which isn't always true
variable "public_subnet_cidrs" {
  description = "List of public cidrs, for all available availability zones. Example: 10.0.0.0/24 and 10.0.1.0/24"
  type        = list(string)
  default     = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
}

variable "private_subnet_cidrs" {
  description = "List of private cidrs, for all available availability zones. Example: 10.0.0.0/24 and 10.0.1.0/24"
  type        = list(string)
  default     = ["10.0.32.0/19", "10.0.64.0/19", "10.0.96.0/19"]
}

variable "database_subnet_cidrs" {
  description = "List of database cidrs, for all available availability zones. Example: 10.0.0.0/24 and 10.0.1.0/24"
  type        = list(string)
  default     = ["10.0.20.0/22", "10.0.24.0/22", "10.0.28.0/22"]
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
}

variable "volume_size" {
  default = 20
}

variable "spot_volume_size" {
  default = 20
}

variable "extra_userdata" {
  type        = string
  description = "Additional EC2 user data commands that will be passed to EKS nodes"
  default     = <<USERDATA
echo ""
USERDATA

}

variable "jhub_cognito_auth_enabled" {
  default = false
}

variable "jhub_cognito_user_groups" {
  default = []
  description = "List of jhub user groups manage by cognito user pool"
  type = list(object({
    name = string
    description = string
    precedence = number
  }))
}