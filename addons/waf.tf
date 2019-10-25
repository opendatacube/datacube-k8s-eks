# AWS WAF Rules for OWASP Top 10 security risks protection.
#
# The module which is defined on repository: https://github.com/traveloka/terraform-aws-waf-owasp-top-10-rules
# For a better understanding of what are those parameters mean,
# please read the description of each variable in the variables.tf file:
# https://github.com/traveloka/terraform-aws-waf-owasp-top-10-rules/blob/master/variables.tf
module "owasp_top_10_rules" {
  source  = "traveloka/waf-owasp-top-10-rules/aws"
  version = "v0.2.0"

  product_domain = "wafowasp"
  service_name   = "wafowasp"
  environment    = "${var.waf_environment}"
  description    = "OWASP Top 10 rules for waf"

  target_scope      = "regional" # [IMPORTANT] this variable value should be set to regional
  create_rule_group = "true"

  max_expected_uri_size          = "512"
  max_expected_query_string_size = "1024"
  max_expected_body_size         = "4096"
  max_expected_cookie_size       = "4093"

  csrf_expected_header = "x-csrf-token"
  csrf_expected_size   = "36"
}

/*
# A rate limiter rule
# Read more:
# https://www.terraform.io/docs/providers/aws/r/wafregional_rate_based_rule.html
resource "aws_wafregional_rate_based_rule" "rate_limiter_rule" {
  name        = "waf-rate-limiter-rule"
  metric_name = "wafRateLimiterRule"

  rate_key   = "IP"
  rate_limit = "2000"
}
*/

# Create an S3 bucket to store cf logs
resource "aws_s3_bucket" "waf_log_bucket" {
  bucket = var.waf_log_bucket
  region = var.region
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "Logs for wafowasp"
  }
}

# Policy document that will allow the Firehose to assume an IAM Role.
data "aws_iam_policy_document" "firehose_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "firehose.amazonaws.com",
      ]
    }
  }
}

# IAM Role for the Firehose, so it able to access those resources above.
resource "aws_iam_role" "waf_firehose_role" {
  name        = "waf_firehose_role"
  path        = "/service-role/firehose/"
  description = "Service Role for wafowasp-WebACL Firehose"

  assume_role_policy    = "${data.aws_iam_policy_document.firehose_assume_role_policy.json}"
}

# Policy document that will be attached to the S3 Bucket, to make the bucket accessible by the Firehose.
data "aws_iam_policy_document" "allow_s3_actions" {
  statement {
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "${aws_iam_role.waf_firehose_role.arn}",
      ]
    }

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.waf_log_bucket.arn}",
      "${aws_s3_bucket.waf_log_bucket.arn}/*",
    ]
  }
}

# Attach the policy above to the bucket.
resource "aws_s3_bucket_policy" "webacl_log_bucket_policy" {
  bucket = "${aws_s3_bucket.waf_log_bucket.id}"
  policy = "${data.aws_iam_policy_document.allow_s3_actions.json}"
}

# This log group for storing delivery error information.
resource "aws_cloudwatch_log_group" "firehose_error_logs" {
  name              = "/aws/kinesisfirehose/aws-waf-logs-wafowasp-WebACL"
  retention_in_days = "14"
}

resource "aws_cloudwatch_log_stream" "firehose_error_log_stream" {
  name           = "firehose-error-log-stream"
  log_group_name = "${aws_cloudwatch_log_group.firehose_error_logs.name}"
}

data "aws_iam_policy_document" "allow_put_log_events" {
  statement {
    sid = "AllowWritingToLogStreams"
    actions = [
      "logs:PutLogEvents",
    ]
    effect = "Allow"
    resources = [
      "${aws_cloudwatch_log_stream.firehose_error_log_stream.arn}",
    ]
  }
}

# Attach the policy above to the IAM Role.
resource "aws_iam_role_policy" "allow_put_log_events" {
  name = "AllowWritingToLogStreams"
  role = "${aws_iam_role.waf_firehose_role.name}"
  policy = "${data.aws_iam_policy_document.allow_put_log_events.json}"
}

# Creating the Firehose.
resource "aws_kinesis_firehose_delivery_stream" "waf_delivery_stream" {
  name        = "aws-waf-logs-wafowasp-WebACL-delivery-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = "${aws_iam_role.waf_firehose_role.arn}"
    bucket_arn = "${aws_s3_bucket.waf_log_bucket.arn}"

    buffer_size     = "${var.waf_firehose_buffer_size}"
    buffer_interval = "${var.waf_firehose_buffer_interval}"

    prefix              = "logs/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    error_output_prefix = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}"

    cloudwatch_logging_options {
      enabled         = "true"
      log_group_name  = "${aws_cloudwatch_log_group.firehose_error_logs.name}"
      log_stream_name = "${aws_cloudwatch_log_stream.firehose_error_log_stream.name}"
    }
  }

  tags = {
    Name          = "aws-waf-logs-wafowasp-WebACL-delivery_stream"
  }
}

# Read more of what are those parameters mean:
# https://www.terraform.io/docs/providers/aws/r/wafregional_web_acl.html
resource "aws_wafregional_web_acl" "waf_webacl" {
  name = "waf-owasp-WebACL"
  metric_name = "wafOwaspWebACL"

  # Configuration block to enable WAF logging.
  logging_configuration {
    # Amazon Resource Name (ARN) of Kinesis Firehose Delivery Stream
    log_destination = "${aws_kinesis_firehose_delivery_stream.waf_delivery_stream.arn}"
  }

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

  /*
  rule {
    priority = "1"
    rule_id  = "${aws_wafregional_rate_based_rule.rate_limiter_rule.id}"
    type     = "RATE_BASED"

    # Only used if type is NOT `GROUP`.
    # The action that CloudFront or AWS WAF takes
    # when a web request matches the conditions in the rule.
    action {
      # Valid values are `ALLOW`, `BLOCK`, and `COUNT`.
      type = "BLOCK"
    }
  }
  */
}

/*
# Only available for regional WAF - association with alb, will enable the WAF WebACL on a certain ALB
resource "aws_wafregional_web_acl_association" "alb" {
  resource_arn = "arn:aws:elasticloadbalancing:ap-southeast-1:<account-id>:loadbalancer/app/<lb-name>/<lb-id>" # ARN of the ALB
  web_acl_id   = "${aws_wafregional_web_acl.waf_webacl.id}"
}
*/