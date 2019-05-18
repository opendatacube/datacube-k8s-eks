variable "origin_id" {
  default     = "default_origin"
  description = "User defined unique ID for the the origin"
}

variable "origin_http_port" {
  default     = 80
  description = "HTTP port the origin listens on"
}

variable "origin_https_port" {
  default     = 443
  description = "HTTPS port the origin listens on"
}

variable "origin_protocol_policy" {
  type        = "string"
  default     = "match-viewer"
  description = "Which protocol is used to connect to origin, http-only, https-only, match-viewer"
}

variable "origin_timeout" {
  default     = 60
  description = "The time cloudfront will wait for a response"
}

variable "enable_distribution" {
  default     = false
  description = "Enables the cloudfront distribution"
}

variable "enable_ipv6" {
  default = true
}

variable "default_allowed_methods" {
  default = ["GET", "HEAD"]
}

variable "default_cached_methods" {
  default = ["GET", "HEAD"]
}

variable "min_ttl" {
  default = 0
}

variable "max_ttl" {
  default = 31536000
}

variable "default_ttl" {
  default = 86400
}

variable "price_class" {
  default     = "PriceClass_All"
  description = "The Price class for this distribution, can be PriceClass_100, PriceClass_200 or PriceClass_All"
}

variable "enable" {
  default     = false
  description = "Whether the cloudfront distribution should be created"
}

variable "log_bucket" {
  description = "S3 Bucket to store logs"
}

variable "log_prefix" {
  default     = ""
  description = "Prefix for logs in this distribution"
}

variable "app_domain" {
  default = "*.services"
}

variable "custom_aliases" {
  type    = "list"
  default = []
}

variable "app_zone" {}

variable "origin_domain" {}

variable "create_certificate" {}
