# AWS Datacube Terraform EKS

Terraform module which creates an EKS cluster for running Open Data Cube

EKS cluster with:
- S3 gateway
- RDS
- Cloudfront
- ACM Certificate

Optional add-ons:
- Cloudfront log export

# Requirements
- kubectl installed
- A public routable Route53 zone
- aws-iam-authenticator installed 
https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html

# Todo
- Process for patching workers
https://docs.aws.amazon.com/eks/latest/userguide/migrate-stack.html

- Process for patching masters
https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html

- Install default charts using kubernetes / helm providers as addons


# Usage

TBD