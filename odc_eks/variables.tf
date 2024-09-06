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
  default     = true
}
## Create VPC = false
variable "vpc_id" {
  type        = string
  description = "VPC ID to use if create_vpc = false"
  default     = ""
}

variable "private_subnets" {
  type        = list(string)
  description = "list of private subnets to use if create_vpc = false"
  default     = []
}

variable "database_subnets" {
  type        = list(string)
  description = "list of database subnets to use if create_vpc = false"
  default     = []
}

variable "public_subnets" {
  type        = list(string)
  description = "list of public subnets to use if create_vpc = false"
  default     = []
}

variable "public_route_table_ids" {
  type        = list(string)
  description = "Will just pass through to outputs if use create_vpc = false. For backwards compatibility."
  default     = []
}

variable "private_route_table_ids" {
  type        = list(string)
  description = "Will just pass through to outputs if use create_vpc = false. For backwards compatibility."
  default     = []
}


## Create VPC = true
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "secondary_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "Secondary VPC CIDRs, optional, default no secondary CIDRs"
}


variable "public_subnet_cidrs" {
  description = "List of public cidrs, for all available availability zones. Example: 10.0.0.0/24 and 10.0.1.0/24"
  type        = list(string)
  default     = []
}

variable "public_subnet_names" {
  type        = list(string)
  description = "list of public subnet names to use"
  default     = []
}

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  type        = bool
  default     = true
}

variable "private_subnet_cidrs" {
  description = "List of private cidrs, for all available availability zones. Example: 10.0.0.0/24 and 10.0.1.0/24"
  type        = list(string)
  default     = []
}

variable "private_subnet_names" {
  type        = list(string)
  description = "list of private subnet names to use"
  default     = []
}

variable "database_subnet_cidrs" {
  description = "List of database cidrs, for all available availability zones. Example: 10.0.0.0/24 and 10.0.1.0/24"
  type        = list(string)
  default     = []
}

variable "database_subnet_names" {
  type        = list(string)
  description = "list of database subnet names to use"
  default     = []
}

variable "private_subnet_elb_role" {
  type        = string
  description = "ELB role for private subnets "
  default     = "internal-elb"
}

variable "public_subnet_elb_role" {
  type        = string
  description = "ELB role for public subnets "
  default     = "elb"
}

variable "enable_s3_endpoint" {
  type        = bool
  description = "Whether to provision an S3 endpoint to the VPC. Default is set to 'true'"
  default     = true
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Whether to provision a NAT Gateway in the VPC. Default is set to 'true'"
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

variable "create_igw" {
  type        = bool
  description = "Whether to provision an Internet Gateway in the VPC. Default is true (False for private routing)"
  default     = true
}

variable "create_vpc_flow_logs" {
  type        = bool
  description = "Whether to create VPC flow logs. Default is set to 'false'"
  default     = false
}

variable "flow_log_max_aggregation_interval" {
  description = "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds"
  type        = number
  default     = 600
}

variable "flow_log_traffic_type" {
  description = "The type of traffic to capture. Valid values: ACCEPT, REJECT, ALL"
  type        = string
  default     = "ALL"
}

variable "flow_log_file_format" {
  description = "(Optional) The format for the flow log. Valid values: `plain-text`, `parquet`"
  type        = string
  default     = "plain-text"
}

variable "create_flow_log_s3_bucket" {
  type        = bool
  description = "Whether to create a S3 bucket for the vpc flow logs. Default is set to 'false'"
  default     = false
}

variable "flow_log_s3_bucket_name" {
  description = "The name of the bucket used to store the logs"
  type        = string
  default     = ""
}

variable "flow_log_s3_bucket_prefix" {
  description = "The name of the prefix used to store the logs on S3"
  type        = string
  default     = ""
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

variable "volume_encrypted" {
  default     = null
  type        = bool
  description = "Whether to encrypt the root EBS volume."
}

variable "volume_size" {
  default = 20
  type    = number
}

variable "volume_type" {
  default     = ""
  type        = string
  description = "Override EBS volume type e.g. gp2, gp3"
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

variable "extra_bootstrap_args" {
  type        = string
  description = "Additional bootstrap.sh command-line arguments (e.g. '--arg1=value --arg2')"
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

variable "enabled_cluster_log_types" {
  type        = list(string)
  description = "Enable EKS control plane logging to CloudWatch"
  default     = []
}

variable "enable_custom_cluster_log_group" {
  type        = bool
  description = "Create a custom CloudWatch Log Group for the cluster. If you supply enabled_cluster_log_types and leave this false, EKS will create a log group automatically with default retention values."
  default     = false
}

variable "log_retention_period" {
  type        = number
  description = "Retention period in days of enabled EKS cluster logs"
  default     = 30
}

variable "metadata_options" {
  description = "Metadata options for the EKS node launch templates. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#metadata-options"
  type        = map(any)
  default     = {}

  # If http_tokens is required then http_endpoint must be enabled.
  validation {
    condition     = lookup(var.metadata_options, "http_tokens", null) != "required" || lookup(var.metadata_options, "http_endpoint", null) == "enabled"
    error_message = "If http_tokens is required for nodes then http_endpoint must be enabled."
  }
}