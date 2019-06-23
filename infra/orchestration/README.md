# Datakube Orchestration
This folder provides infrastructure for running Datakube K8s orchestration containers to support Near Real Time (NRT) Datacube datasets in Amazon S3. The infrastructure consists of:
* SQS Queues per service that receive messages from the SNS topic
* Policy that allows a container with a `${var.cluster_name}-orchestration` IAM annotation to get messages from the SQS queues. 

## Setup
### Pre-requisites
* Terraform >= 0.12.0
* AWS CLI

### AWS Pre-requisites
* S3 Bucket with SNS notifcation

### Deploying
In your workspace create `orchestration.terraform.tfvars` and specify the following:
* `bucket` The name of the S3 bucket with the SNS topic you wish to subscribe to
* `topic_arn` The ARN of the SNS topic you wish to subscribe to
* `services` A list of names which will correspond to a new SQS queue per name
Then run `deploy.sh $WORKSPACE $WORKSPACEPATH`
