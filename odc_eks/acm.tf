# Create a wildcard cert for use on the alb
resource "aws_acm_certificate" "wildcard_cert" {
  count             = var.create_certificate ? 1 : 0
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"
}

# Automatically validate the cert using DNS validation
data "aws_route53_zone" "wildcard_zone" {
  count        = var.create_certificate ? 1 : 0
  name         = var.domain_name
  private_zone = false
}

locals {
  # Use a local to set the domain_valid_options to an empty set when the certs aren't created
  # this will prevent the resource from being created and prevents an error when trying to access the index [0] when it disabled
  wildcard_cert_domain_validation_options = var.create_certificate ? aws_acm_certificate.wildcard_cert[0].domain_validation_options : []
}

resource "aws_route53_record" "wildcard_cert_validation" {

  zone_id = data.aws_route53_zone.wildcard_zone[0].id

  for_each = {
    for dvo in local.wildcard_cert_domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  type    = each.value.type

  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "wildcard_cert" {
  count                   = var.create_certificate ? 1 : 0
  certificate_arn         = aws_acm_certificate.wildcard_cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.wildcard_cert_validation : record.fqdn]
}

