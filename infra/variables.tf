variable "region" {
  default = "ap-southeast-2"
}

variable "owner" {
  default     = "Team name"
  description = "Identifies who is responsible for these resources"
}

variable "cluster_name" {
  default = "datacube-eks"
}

variable "admin_access_CIDRs" {
  description = "Locks ssh and api access to these IPs"
  type        = "map"

  # No admin access
  default = {}
}

variable "users" {
  description = "A list of users that will be given access to the cluster"
  type        = "list"
}


variable "domain_name" {
  description = "The domain name to be used by for applications deployed to the cluster and using ingress"
  type        = "string"
}

variable "cloudfront_log_bucket" {
  default     = "dea-cloudfront-logs.s3.amazonaws.com"
  description = "S3 Bucket to store cloudfront logs"
}

variable "create_certificate" {
  default = false
}

# Database
variable "db_hostname" {
  default = "database"
}

variable "db_domain_name" {
  default = "internal"
}

variable "db_name" {
  default = "datakube"
}

variable "db_multi_az" {
  default = false
}

variable "store_db_credentials" {
  default = false
  description = "If true, db credentials will be stored in a kubernetes secret"
}

# VPC & subnets
# ===========
variable "vpc_cidr" {
  type = "string"
  default = "10.0.0.0/16"
}

# TODO Cloud posse have an terraform method for calculating the subnet ids. Might make life easier.
# TODO default CIDRS assume 3 availability zones which isn't always true
variable "public_subnet_cidrs" {
  description = "List of public cidrs, for all available availability zones. Example: 10.0.0.0/24 and 10.0.1.0/24"
  type        = "list"
  default     = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
}

variable "private_subnet_cidrs" {
  description = "List of private cidrs, for all available availability zones. Example: 10.0.0.0/24 and 10.0.1.0/24"
  type        = "list"
  default     = ["10.0.32.0/19", "10.0.64.0/19", "10.0.96.0/19"]
}

variable "database_subnet_cidrs" {
  description = "List of database cidrs, for all available availability zones. Example: 10.0.0.0/24 and 10.0.1.0/24"
  type        = "list"
  default     = ["10.0.20.0/22", "10.0.24.0/22", "10.0.28.0/22"]
}