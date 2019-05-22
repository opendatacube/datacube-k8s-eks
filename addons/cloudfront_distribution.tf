# Required variables

variable "cf_enable" {
  default     = false
  description = "Whether the cloudfront distribution should be created"
}

variable "cf_dns_record" {
  default     = "ows"
  description = "The domain we will point to cloudfront"
}

variable "cf_origin_dns_record" {
  default     = "cached-alb"
  description = "The domain of our load balancer that will be created by kubernetes"
}

variable "cf_custom_aliases" {
  type    = "list"
  default = []
}

variable "cf_certificate_arn" {
  default     = ""
  description = "When setting additional aliases you will need to provide your own us-east-1 certificate"
}

variable "cf_certificate_create" {
  default = true
}

variable "cf_log_bucket" {
  default     = ""
  description = "The name of the bucket to store cf logs in"
}

variable "cf_log_bucket_create" {
  default = true
}

# Optional tuning variables

variable "cf_origin_protocol_policy" {
  default     = "http-only"
  description = "Which protocol is used to connect to origin, http-only, https-only, match-viewer"
}

variable "cf_origin_timeout" {
  default     = 60
  description = "The time cloudfront will wait for a response"
}

variable "cf_default_allowed_methods" {
  default = ["GET", "HEAD", "POST", "OPTIONS", "PUT", "PATCH", "DELETE"]
}

variable "cf_default_cached_methods" {
  default = ["GET", "HEAD"]
}

variable "cf_min_ttl" {
  default = 0
}

variable "cf_max_ttl" {
  default = 31536000
}

variable "cf_default_ttl" {
  default = 86400
}

variable "cf_price_class" {
  default     = "PriceClass_All"
  description = "The Price class for this distribution, can be PriceClass_100, PriceClass_200 or PriceClass_All"
}

# Create a new certificate, this must be in us-east-1 to work with cloudfront
provider "aws" {
  region = "us-east-1"
  alias  = "us"
}

resource "aws_acm_certificate" "cert" {
  provider          = "aws.us"
  count             = "${var.cf_certificate_create * var.cf_enable}"
  domain_name       = "${var.cf_dns_record}.${var.domain_name}"
  validation_method = "DNS"
}

# Automatically validate the cert using DNS validation
data "aws_route53_zone" "zone" {
  count        = "${var.cf_certificate_create * var.cf_enable}"
  name         = "${var.domain_name}"
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  count   = "${var.cf_certificate_create * var.cf_enable}"
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  provider = "aws.us"

  count                   = "${var.cf_certificate_create * var.cf_enable}"
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}

locals {
  # set certificate_arn to either the existing cert of the generated cert
  certificate_arn = "${coalesce(join("", list(var.cf_certificate_arn)), join("", aws_acm_certificate_validation.cert.*.certificate_arn) )}"

  origin_domain = "${var.cf_origin_dns_record}.${var.domain_name}"

  # Creates a basic cloudfront disribution with a custom (i.e. not S3) origin
  default_alias = ["${var.cf_dns_record}.${var.domain_name}"]
  alias         = "${compact(concat(local.default_alias, var.cf_custom_aliases))}"
}

# Create an S3 bucket to store cf logs
resource "aws_s3_bucket" "cloudfront_log_bucket" {
  count  = "${var.cf_log_bucket_create * var.cf_enable}"
  bucket = "${var.cf_log_bucket}"
  region = "${var.region}"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags {
    Name = "Cloudfront Logs for ${var.cluster_name}"
  }
}

# Create our cloudfront distribution
resource "aws_cloudfront_distribution" "cloudfront" {
  count = "${var.cf_enable ? 1 : 0}"

  origin {
    domain_name = "${local.origin_domain}"
    origin_id   = "${var.cluster_name}_${terraform.workspace}_origin"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "${var.cf_origin_protocol_policy}"
      origin_ssl_protocols     = ["TLSv1.1", "TLSv1.2"]
      origin_keepalive_timeout = "${var.cf_origin_timeout}"
      origin_read_timeout      = "${var.cf_origin_timeout}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = ""
  aliases             = ["${local.alias}"]

  default_cache_behavior {
    allowed_methods  = "${var.cf_default_allowed_methods}"
    cached_methods   = "${var.cf_default_cached_methods}"
    target_origin_id = "${var.cluster_name}_${terraform.workspace}_origin"

    forwarded_values {
      query_string = true
      headers      = ["Host"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = "${var.cf_min_ttl}"
    max_ttl                = "${var.cf_max_ttl}"
    default_ttl            = "${var.cf_default_ttl}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  logging_config {
    bucket = "${var.cf_log_bucket}"
    prefix = "${var.cluster_name}_${terraform.workspace}_cf"
  }

  viewer_certificate {
    acm_certificate_arn = "${local.certificate_arn}"
    ssl_support_method  = "sni-only"
  }

  price_class = "${var.cf_price_class}"

  # Don't cache 500, 502, 503 or 504 errors
  custom_error_response {
    error_caching_min_ttl = "0"
    error_code            = "500"
  }

  custom_error_response {
    error_caching_min_ttl = "0"
    error_code            = "502"
  }

  custom_error_response {
    error_caching_min_ttl = "0"
    error_code            = "503"
  }

  custom_error_response {
    error_caching_min_ttl = "0"
    error_code            = "504"
  }
}

# Create a DNS record that points to cloudfront distribution
data "aws_route53_zone" "selected" {
  count = "${var.cf_enable ? 1 : 0}"
  name  = "${var.domain_name}"
}

resource "aws_route53_record" "www" {
  count   = "${var.cf_enable ? 1 : 0}"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${var.cf_dns_record}"
  type    = "CNAME"
  ttl     = "30"
  records = ["${aws_cloudfront_distribution.cloudfront.*.domain_name}"]
}
