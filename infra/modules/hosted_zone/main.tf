# Create hosted zone for mgmt controls

data "aws_route53_zone" "selected" {
  name = "${var.zone}"
}

resource "aws_route53_zone" "new" {
  name = "${var.domain}.${var.zone}"

  tags {
    owner      = "${var.owner}"
    cluster    = "${var.cluster_name}"
    workspace  = "${terraform.workspace}"
    Created_by = "terraform"
  }
}

resource "aws_route53_record" "dev-ns" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${var.domain}.${var.zone}"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.new.name_servers.0}",
    "${aws_route53_zone.new.name_servers.1}",
    "${aws_route53_zone.new.name_servers.2}",
    "${aws_route53_zone.new.name_servers.3}",
  ]
}
