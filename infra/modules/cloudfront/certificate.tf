# Create a new certificate
provider "aws" {
  region = "us-east-1"
  alias  = "us"
}

resource "aws_acm_certificate" "cert" {
  provider          = "aws.us"
  count             = "${var.create_certificate}"
  domain_name       = "${var.app_domain}.${var.app_zone}"
  validation_method = "DNS"
}

data "aws_route53_zone" "zone" {
  count        = "${var.create_certificate}"
  name         = "${var.app_zone}"
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  count   = "${var.create_certificate}"
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  provider = "aws.us"

  count                   = "${var.create_certificate}"
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}

# Or use an existing one
data "aws_acm_certificate" "default" {
  provider = "aws.us"

  # only use if we're not creating certificate
  count    = "${var.create_certificate ? 0 : 1}"
  domain   = "${var.app_domain}.${var.app_zone}"
  statuses = ["ISSUED"]
  count    = "${var.enable ? 1 : 0}"
}

locals {
  # set certificate_arn to either the generated cert of the existing cert
  certificate_arn = "${coalesce(join("", aws_acm_certificate_validation.cert.*.certificate_arn), join("", data.aws_acm_certificate.default.*.arn) )}"
}
