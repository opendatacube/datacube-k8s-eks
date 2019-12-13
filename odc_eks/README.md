# AWS Datacube Terraform EKS

Terraform module which creates an Open Data Cube EKS cluster

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

# Usage

TBD