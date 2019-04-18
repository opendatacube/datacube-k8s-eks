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

# Worker node config
variable "default_worker_instance_type" {
  default = "m4.large"
}

variable "min_nodes" {
  default = 2
}

variable "max_nodes" {
  default = 6
}

variable "spot_nodes_enabled" {
  default = false
}

variable "min_spot_nodes" {
  default = 0
}

variable "max_spot_nodes" {
  default = 2
}

variable "max_spot_price" {
  default = "0.40"
}

variable "dask_nodes_enabled" {
  default = false
}

variable "min_dask_spot_nodes" {
  default = 0
}

variable "max_dask_spot_nodes" {
  default = 2
}

variable "max_dask_spot_price" {
  default = "0.40"
}

variable "green_nodes_enabled" {
  default = true
}

variable "green_ami_image_id" {
  default = ""
}

variable "blue_nodes_enabled" {
  default = false
}

variable "blue_ami_image_id" {
  default = ""
}

locals {
  # Check if optional green nodes should be enabled
  green_spot_nodes_enabled = "${var.green_nodes_enabled && var.spot_nodes_enabled ? 1 : 0 }"
  green_dask_nodes_enabled = "${var.green_nodes_enabled && var.dask_nodes_enabled ? 1 : 0 }"

  # Check if optional blue nodes should be enabled
  blue_spot_nodes_enabled = "${var.blue_nodes_enabled && var.spot_nodes_enabled ? 1 : 0 }"
  blue_dask_nodes_enabled = "${var.blue_nodes_enabled && var.dask_nodes_enabled ? 1 : 0 }"
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

# Add-ons
variable "addon_cloudwatch_logging_enabled" {
  default = true
}

variable "addon_cloudwatch_log_group" {
  default     = "datakube"
  description = "the name of your log group, will need to match fluentd config"
}

variable "addon_cloudwatch_log_retention" {
  default     = 90
  description = "The number of days to keep logs"
}

variable "addon_alb_ingress_enabled" {
  default = true
}

variable "addon_cluster_autoscaler_enabled" {
  default = true
}

variable "addon_datacube_wms_enabled" {
  default = true
}

variable "addon_datacube_wps_enabled" {
  default = true
}

variable "addon_external_dns_enabled" {
  default = true
}
