# Required variables

variable "cf_enable" {
  default     = false
  description = "Whether the cloudfront distribution should be created"
}

variable "cf_dns_record" {
  default     = ""
  description = "The domain we will point to cloudfront"
}

variable "cf_origin_dns_record" {
  default     = ""
  description = "The domain of our load balancer that will be created by kubernetes"
}

variable "cf_custom_aliases" {
  type        = list(string)
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution"
  default     = []
}

variable "cf_certificate_arn" {
  default     = ""
  description = "Provide your own us-east-1 certificate ARN when setting additional aliases"
}

variable "cf_certificate_create" {
  default = true
}

variable "cf_log_bucket" {
  default     = ""
  description = "The name of the bucket to store cf logs in"
}

variable "cf_log_bucket_create" {
  default = false
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
  alias = "us-east-1"
}

resource "aws_acm_certificate" "cert" {
  provider                  = aws.us-east-1
  count                     = (var.cf_certificate_create && var.cf_enable) ? 1 : 0
  domain_name               = "${var.cf_dns_record}.${local.cf_acm_domains[0]}"
  subject_alternative_names = slice(local.cf_acm_domains, 1, length(local.cf_acm_domains))
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Automatically validate the cert using DNS validation
data "aws_route53_zone" "zone" {
  count        = (var.cf_certificate_create && var.cf_enable) ? 1 : 0
  name         = var.domain_name
  private_zone = false
}

locals {
  # Use a local to set the domain_valid_options to an empty set when the certs aren't created
  # this will prevent the resource from being created and prevents an error when trying to access the index [0] when it disabled
  cert_domain_validation_options = (var.cf_certificate_create && var.cf_enable) ? aws_acm_certificate.cert[0].domain_validation_options : []
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in local.cert_domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.zone[0].id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60

}

resource "aws_acm_certificate_validation" "cert" {
  count                   = (var.cf_certificate_create && var.cf_enable) ? 1 : 0
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

locals {
  # set certificate_arn to either the existing cert or the generated cert
  generated_cert_arn = (var.cf_certificate_create && var.cf_enable) ? aws_acm_certificate_validation.cert[0].certificate_arn : ""
  certificate_arn    = (var.cf_certificate_arn != "") ? var.cf_certificate_arn : local.generated_cert_arn

  origin_domain = "${var.cf_origin_dns_record}.${var.domain_name}"

  # List of domains for cf certificate
  cf_acm_domains = (length(var.cf_custom_aliases) == 0) ? [var.domain_name] : concat([var.domain_name], var.cf_custom_aliases)

  # Creates a basic cloudfront disribution with a custom (i.e. not S3) origin
  default_alias = ["${var.cf_dns_record}.${var.domain_name}"]
  alias         = compact(concat(local.default_alias, var.cf_custom_aliases))

  # Get a bucket name without an extention: .s3.amazonaws.com
  log_bucket = element(split(".s3.amazonaws.com", var.cf_log_bucket), 0)
}

# create a policy document for the log bucket
data "aws_iam_policy_document" "cloudfront_log_bucket_policy_doc" {
  count = (var.cf_log_bucket_create && var.cf_enable) ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions = [
      "s3:GetBucketAcl",
      "s3:PutBucketAcl"
    ]

    resources = [
      "arn:aws:s3:::${local.log_bucket}"
    ]
  }
}

# Create an S3 bucket to store cf logs
resource "aws_s3_bucket" "cloudfront_log_bucket" {
  count  = (var.cf_log_bucket_create && var.cf_enable) ? 1 : 0
  bucket = local.log_bucket
  acl    = "private"
  policy = data.aws_iam_policy_document.cloudfront_log_bucket_policy_doc[0].json

  # Needed if you want to delete the bucket
  # force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = merge(
    {
      Name        = local.log_bucket
      owner       = var.owner
      namespace   = var.namespace
      environment = var.environment
    },
    var.tags
  )
}

# Create our cloudfront distribution
resource "aws_cloudfront_distribution" "cloudfront" {
  count      = var.cf_enable ? 1 : 0
  depends_on = [aws_s3_bucket.cloudfront_log_bucket]

  origin {
    domain_name = local.origin_domain
    origin_id   = "${module.eks.cluster_id}_origin"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = var.cf_origin_protocol_policy
      origin_ssl_protocols     = ["TLSv1.1", "TLSv1.2"]
      origin_keepalive_timeout = var.cf_origin_timeout
      origin_read_timeout      = var.cf_origin_timeout
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = ""
  aliases             = local.alias

  default_cache_behavior {
    allowed_methods  = var.cf_default_allowed_methods
    cached_methods   = var.cf_default_cached_methods
    target_origin_id = "${module.eks.cluster_id}_origin"

    forwarded_values {
      query_string = true
      headers      = ["Host"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = var.cf_min_ttl
    max_ttl                = var.cf_max_ttl
    default_ttl            = var.cf_default_ttl
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  logging_config {
    bucket = "${local.log_bucket}.s3.amazonaws.com"
    prefix = "${module.eks.cluster_id}-cf"
  }

  viewer_certificate {
    acm_certificate_arn = local.certificate_arn
    ssl_support_method  = "sni-only"
  }

  price_class = var.cf_price_class

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
  count = var.cf_enable ? 1 : 0
  name  = var.domain_name
}

resource "aws_route53_record" "www" {
  count   = var.cf_enable ? 1 : 0
  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = var.cf_dns_record
  type    = "CNAME"
  ttl     = "30"
  records = aws_cloudfront_distribution.cloudfront.*.domain_name
}