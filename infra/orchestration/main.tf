terraform {
  required_version = ">= 0.12.0"

  backend "s3" {
    # Force encryption
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {
}

resource "aws_sns_topic_subscription" "sqs_subscriptions" {
  count     = length(var.services)
  topic_arn = var.topic_arn
  protocol  = "sqs"
  endpoint  = element(aws_sqs_queue.queues.*.arn, count.index)
}

resource "aws_sqs_queue" "queues" {
  count = length(var.services)

  name              = "${var.cluster_name}-${element(var.services, count.index)}"
  kms_master_key_id = aws_kms_alias.sqs.arn
}

resource "aws_sqs_queue_policy" "queue_policy" {
  count     = length(var.services)
  queue_url = element(aws_sqs_queue.queues.*.id, count.index)

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"MySQSPolicy001",
      "Effect":"Allow",
      "Principal":"*",
      "Action":"sqs:SendMessage",
      "Resource":"${element(aws_sqs_queue.queues.*.arn, count.index)}",
      "Condition":{
        "ArnEquals":{
          "aws:SourceArn":"${var.topic_arn}"
        }
      }
    }
  ]
}
POLICY

}

# ======================================
# Orchestration Role
resource "aws_iam_role" "orchestration" {
  name = "${var.cluster_name}-orchestration"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/nodes.${var.cluster_name}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "orchestration" {
name = "${var.cluster_name}-orchestration"
role = aws_iam_role.orchestration.id

policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "sqs:ReceiveMessage",
          "sqs:GetQueueUrl",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ListQueues"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["S3:GetObject"],
      "Resource": [
        "arn:aws:s3:::${var.bucket}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": ["kms:Decrypt"],
      "Resource": [
        "${aws_kms_key.sqs.arn}"
      ]
    }
  ]
}
EOF

}

#======================
# SQS Encryption

resource "aws_kms_key" "sqs" {
description = "KMS Key for encrypting SQS Queue for ${var.bucket} for ${var.cluster_name} notifications"
deletion_window_in_days = 30
policy = <<POLICY
  {
   "Version": "2012-10-17",
      "Statement": [
      {
        "Sid": "Allow administration of the key",
        "Effect": "Allow",
        "Principal": { "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
        "Action": [
            "kms:Create*",
            "kms:Describe*",
            "kms:Enable*",
            "kms:List*",
            "kms:Put*",
            "kms:Update*",
            "kms:Revoke*",
            "kms:Disable*",
            "kms:Get*",
            "kms:Delete*",
            "kms:ScheduleKeyDeletion",
            "kms:CancelKeyDeletion"
        ],
        "Resource": "*"
      },
      {
         "Effect": "Allow",
         "Principal": {
            "Service": "sns.amazonaws.com"
         },
         "Action": [
            "kms:GenerateDataKey",
            "kms:Decrypt"
         ],
         "Resource": "*"
       },
       {
          "Sid": "",
          "Effect": "Allow",
          "Principal": {
            "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          },
          "Action": "kms:Decrypt",
          "Resource": "*"
      }]
  }
POLICY

}

resource "aws_kms_alias" "sqs" {
  name          = "alias/${var.cluster_name}-sqs-${var.bucket}"
  target_key_id = aws_kms_key.sqs.key_id
}

