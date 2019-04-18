output "dns_zone_id" {
  value = "${aws_cloudfront_distribution.cloudfront.*.hosted_zone_id}"
}

output "dns_name" {
  value = "${aws_cloudfront_distribution.cloudfront.*.domain_name}"
}