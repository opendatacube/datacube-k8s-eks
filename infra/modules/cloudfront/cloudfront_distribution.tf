# Creates a basic cloudfront disribution with a custom (i.e. not S3) origin

locals {
  default_alias = ["${var.app_domain}.${var.app_zone}"]
  alias         = "${compact(concat(local.default_alias, var.custom_aliases))}"
}

resource "aws_cloudfront_distribution" "cloudfront" {
  count = "${var.enable ? 1 : 0}"

  origin {
    domain_name = "${var.origin_domain}"
    origin_id   = "${var.origin_id}"

    custom_origin_config {
      http_port                = "${var.origin_http_port}"
      https_port               = "${var.origin_https_port}"
      origin_protocol_policy   = "${var.origin_protocol_policy}"
      origin_ssl_protocols     = ["TLSv1.1", "TLSv1.2"]
      origin_keepalive_timeout = "${var.origin_timeout}"
      origin_read_timeout      = "${var.origin_timeout}"
    }
  }

  enabled             = "${var.enable_distribution}"
  is_ipv6_enabled     = "${var.enable_ipv6}"
  default_root_object = ""
  aliases             = ["${local.alias}"]

  default_cache_behavior {
    allowed_methods  = "${var.default_allowed_methods}"
    cached_methods   = "${var.default_cached_methods}"
    target_origin_id = "${var.origin_id}"

    forwarded_values {
      query_string = true
      headers      = ["Host"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = "${var.min_ttl}"
    max_ttl                = "${var.max_ttl}"
    default_ttl            = "${var.default_ttl}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  logging_config {
    bucket = "${var.log_bucket}"
    prefix = "${var.log_prefix}"
  }

  viewer_certificate {
    acm_certificate_arn = "${local.certificate_arn}"
    ssl_support_method  = "sni-only"
  }

  price_class = "${var.price_class}"

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

provider "aws" {
  alias  = "cert"
  region = "us-east-1"
}

data "aws_route53_zone" "selected" {
  count = "${var.enable ? 1 : 0}"
  name  = "${var.app_zone}"
}

resource "aws_route53_record" "www" {
  count   = "${var.enable ? 1 : 0}"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${var.app_domain}"
  type    = "CNAME"
  ttl     = "30"
  records = ["${aws_cloudfront_distribution.cloudfront.*.domain_name}"]
}
