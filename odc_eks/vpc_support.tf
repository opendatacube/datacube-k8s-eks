################################################################################
# Supporting Resources
################################################################################
resource "random_pet" "this" {
  length = 2
}

# S3 Bucket
module "s3_bucket" {
  count   = (var.create_vpc_flow_logs && var.create_flow_log_s3_bucket) ? 1 : 0
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = var.flow_log_s3_bucket_name
  policy = data.aws_iam_policy_document.flow_log_s3[0].json

  tags = var.tags
}

data "aws_iam_policy_document" "flow_log_s3" {
  count = (var.create_vpc_flow_logs && var.create_flow_log_s3_bucket) ? 1 : 0
  statement {
    sid = "AWSLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = ["arn:aws:s3:::${var.flow_log_s3_bucket_name}/AWSLogs/*"]
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