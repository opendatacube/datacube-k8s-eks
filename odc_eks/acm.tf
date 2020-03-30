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

resource "aws_route53_record" "wildcard_cert_validation" {
  count   = var.create_certificate ? 1 : 0
  name    = aws_acm_certificate.wildcard_cert[0].domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.wildcard_cert[0].domain_validation_options[0].resource_record_type
  zone_id = data.aws_route53_zone.wildcard_zone[0].id
  records = [aws_acm_certificate.wildcard_cert[0].domain_validation_options[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "wildcard_cert" {
  count                   = var.create_certificate ? 1 : 0
  certificate_arn         = aws_acm_certificate.wildcard_cert[0].arn
  validation_record_fqdns = [aws_route53_record.wildcard_cert_validation[0].fqdn]
}

