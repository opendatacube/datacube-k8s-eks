# AWS WAF Rules for OWASP Top 10 security risks protection.
#
# The module which is defined on repository: https://github.com/traveloka/terraform-aws-waf-owasp-top-10-rules
# For a better understanding of what are those parameters mean,
# please read the description of each variable in the variables.tf file:
# https://github.com/traveloka/terraform-aws-waf-owasp-top-10-rules/blob/master/variables.tf
module "owasp_top_10_rules" {
  source  = "traveloka/waf-owasp-top-10-rules/aws"
  version = "v0.2.0"

  product_domain = "dea"
  service_name   = "deawaf"
  environment    = "dev"
  description    = "OWASP Top 10 rules for deawaf"

  target_scope      = "regional" # [IMPORTANT] this variable value should be set to regional
  create_rule_group = "true"

  max_expected_uri_size          = "512"
  max_expected_query_string_size = "1024"
  max_expected_body_size         = "4096"
  max_expected_cookie_size       = "4093"

  csrf_expected_header = "x-csrf-token"
  csrf_expected_size   = "36"
}

# A rate limiter rule
# Read more:
# https://www.terraform.io/docs/providers/aws/r/wafregional_rate_based_rule.html
//resource "aws_wafregional_rate_based_rule" "rate_limiter_rule" {
//  name        = "deawaf-rate-limiter-rule"
//  metric_name = "deawafRateLimiterRule"
//
//  rate_key   = "IP"
//  rate_limit = "2000"
//}

# The module which is defined on repository: https://github.com/traveloka/terraform-aws-waf-webacl-supporting-resources
# For a better understanding of what are those parameters mean,
# please read the description of each variable in the variables.tf file:
# https://github.com/traveloka/terraform-aws-waf-webacl-supporting-resources/blob/master/variables.tf
module "webacl_supporting_resources" {
  source  = "traveloka/waf-webacl-supporting-resources/aws"
  version = "v0.1.0"

  product_domain = "dea"
  service_name   = "deawaf"
  environment    = "dev"
  description    = "WebACL for deawaf"

  s3_logging_bucket = "awswaf-logs-451924316694" # TODO: create a bucket and bucket policy. Logging bucket should be in the same region as the bucket.

  firehose_buffer_size     = "128"
  firehose_buffer_interval = "900"
}

# Read more of what are those parameters mean:
# https://www.terraform.io/docs/providers/aws/r/wafregional_web_acl.html
resource "aws_wafregional_web_acl" "deawaf_webacl" {
  # The name or description of the web ACL.
  name = "deawaf-owasp-WebACL"

  # The name or description for the Amazon CloudWatch metric of this web ACL.
  metric_name = "deawafOwaspWebACL"

  # Configuration block to enable WAF logging.
  logging_configuration {
    # Amazon Resource Name (ARN) of Kinesis Firehose Delivery Stream
    log_destination = "${module.webacl_supporting_resources.firehose_delivery_stream_arn}"
  }

  # Configuration block with action that you want AWS WAF to take
  # when a request doesn't match the criteria in any of the rules
  # that are associated with the web ACL.
  default_action {
    # Valid values are `ALLOW` and `BLOCK`.
    type = "ALLOW"
  }

  # Configuration blocks containing rules to associate with the web ACL and the settings for each rule.
  rule {
    # Specifies the order in which the rules in a WebACL are evaluated.
    # Rules with a lower value are evaluated before rules with a higher value.
    priority = "0"

    # ID of the associated WAF rule
    rule_id = "${module.owasp_top_10_rules.rule_group_id}"

    # Valid values are `GROUP`, `RATE_BASED`, and `REGULAR`
    # The rule type, either REGULAR, as defined by Rule,
    # RATE_BASED, as defined by RateBasedRule,
    # or GROUP, as defined by RuleGroup.
    type = "GROUP"

    # Only used if type is `GROUP`.
    # Override the action that a group requests CloudFront or AWS WAF takes
    # when a web request matches the conditions in the rule.
    override_action {
      # Valid values are `NONE` and `COUNT`
      type = "NONE"
    }
  }

//  rule {
//    priority = "1"
//    rule_id  = "${aws_wafregional_rate_based_rule.rate_limiter_rule.id}"
//    type     = "RATE_BASED"
//
//    # Only used if type is NOT `GROUP`.
//    # The action that CloudFront or AWS WAF takes
//    # when a web request matches the conditions in the rule.
//    action {
//      # Valid values are `ALLOW`, `BLOCK`, and `COUNT`.
//      type = "BLOCK"
//    }
//  }
}

# Only available for regional WAF - association with alb, will enable the WAF WebACL on a certain ALB
//resource "aws_wafregional_web_acl_association" "alb" {
//  resource_arn = "arn:aws:elasticloadbalancing:ap-southeast-1:<account-id>:loadbalancer/app/<lb-name>/<lb-id>" # ARN of the ALB
//  web_acl_id   = "${aws_wafregional_web_acl.deawaf_webacl.id}"
//}