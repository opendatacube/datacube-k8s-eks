terraform {
  required_version = ">= 0.11.0"

  backend "s3" {
    # Force encryption
    encrypt = true
  }
}

provider "aws" {
  region = "${var.region}"
}

data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "data_bucket" {
  bucket = "${var.bucket}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${data.aws_s3_bucket.data_bucket.id}"

  topic {
    topic_arn     = "${aws_sns_topic.bucket_topic.arn}"
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = "${var.suffix}"
    filter_prefix = "${var.prefix}"
  }
}

resource "aws_sns_topic" "bucket_topic" {
  name = "${var.topic_name}"
}

resource "aws_sns_topic_policy" "bucket_topic_policy" {
  arn = "${aws_sns_topic.bucket_topic.arn}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sns:Publish",
      "Resource": "${aws_sns_topic.bucket_topic.arn}",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "${data.aws_s3_bucket.data_bucket.arn}"
        }
      }
    },
    {
      "Sid": "public-policy-statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "sns:Receive",
        "sns:Subscribe"
      ],
      "Resource": "${aws_sns_topic.bucket_topic.arn}",
      "Condition": {
        "StringEquals": {
          "SNS:Protocol": [
            "lambda",
            "sqs"
          ]
        }
      }
    }
  ]
}
POLICY
}