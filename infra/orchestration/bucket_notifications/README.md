# Datakube S3 Bucket notification

This infrastructure takes an existing S3 bucket and creates an SNS topic which notifies when new objects are created in the bucket.

It creates the following:
* S3 Bucket notification on file creation
* SNS topic subscribed to the bucket notification

## Requirements
* Terraform >= 0.12
* AWS CLI

## AWS Pre-requisites
* S3 Bucket

## Deployment
In the workspace `bucket_notifications.terraform.tfvars` file specify:
* `bucket` The name of the S3 bucket to apply the notifications to
* `prefix` The prefix of the path that will be subscribed to (Can be blank)
* `suffix` The suffix of the path that will be subscribed to (Can be blank)
* `topic_name` The desired name of the SNS topic
Then run `deploy.sh $WORKSPACE $WORKSPACEPATH`
