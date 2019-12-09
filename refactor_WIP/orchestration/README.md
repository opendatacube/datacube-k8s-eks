# Datakube Orchestration
This folder provides infrastructure for running Datakube K8s orchestration containers to support Near Real Time (NRT) Datacube datasets in Amazon S3. The infrastructure consists of:
* S3 Bucket notification on file creation
* SNS topic subscribed to the bucket notification
* SQS Queues per service that receive messages from the SNS topic
* Policy that allows a container with a `kubernetes-orchestration` IAM annotation to get messages from the SQS queues. 

## Setup
### Pre-requisites
* Terraform >= 0.11.8
* AWS CLI

### AWS Pre-requisites
* S3 Bucket

### Steps
First the `bucket_notification` plan must be applied to the bucket that will be providing notifications. This should be performed as the bucket owner and will create s3 bucket notifications and an SNS topic that will publish notifications.


Given a workspace `$WORKSPACE` such as `datakube-dev`, edit the `../workspaces/$WORKSPACE/terraform.tfvars` files and specify the following terraform variables:
* bucket = "you-bucket-name"
* prefixes = ["s3/prefixes/to/notify/on s3/prefixes/to/notify/on"]
* suffix = ".suffix_of_files_to_notify_on"
* services = ["services", "requiring", "orchestration", "infrastructure"]
* topic_arn = "ARN_of_topic_created_in_bucket_notification"

Once setup, deploy the orchestration infrastructure with `./deploy.sh $WORKSPACE`