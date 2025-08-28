################################################################################
# Supporting Resources
################################################################################
resource "random_pet" "this" {
  length = 2
}

# S3 Bucket
module "s3_bucket" {
  count   = (var.create_flow_log && var.create_flow_log_s3_bucket) ? 1 : 0
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket        = var.flow_log_s3_bucket_name
  attach_policy = true
  policy        = data.aws_iam_policy_document.flow_log_s3[0].json

  force_destroy = true

  tags = var.tags
}

data "aws_iam_policy_document" "flow_log_s3" {
  count = (var.create_flow_log && var.create_flow_log_s3_bucket) ? 1 : 0
  statement {
    sid = "AWSLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = ["arn:aws:s3:::${var.flow_log_s3_bucket_name}/${var.flow_log_s3_bucket_prefix}/AWSLogs/*"]
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:GetBucketAcl"]

    resources = ["arn:aws:s3:::${var.flow_log_s3_bucket_name}"]
  }
}