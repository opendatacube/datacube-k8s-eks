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

# Cloudfront Config for apps with CDN Cache

variable "cloudfront_enabled" {
  default = true
}

variable "app_domain" {
  default     = "app"
  description = "The wildcard domain used to host our apps"
}

variable "cached_app_domain" {
  default     = "services"
  description = "The wildcard domain used to host our apps that will have CDN"
}

variable "mgmt_domain" {
  default     = "mgmt"
  description = "The wildcard domain used to host our apps that will have Authentication"
}

variable "app_zone" {
  description = "The hosted zone to create the app domain"
}

variable "custom_aliases" {
  type    = "list"
  default = []
}

variable "cloudfront_log_bucket" {
  default     = "dea-cloudfront-logs.s3.amazonaws.com"
  description = "S3 Bucket to store cloudfront logs"
}

variable "create_certificate" {
  default = true
}

# Database
variable "db_dns_name" {
  default = "database"
}

variable "db_dns_zone" {
  default = "internal"
}

variable "db_name" {
  default = "datakube"
}

variable "db_multi_az" {
  default = false
}

# VPC & subnets
# ===========
variable "vpc_cidr" {
  type = "string"
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type = "list"
  description = "List of AWS availability zones to create subnets in"
  default = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
}

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