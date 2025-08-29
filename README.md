# Datacube Kubernetes EKS

This repository will build and manage a production scale kubernetes cluster using the AWS EKS engine
for running Open Data Cube applications.

[![Master](https://circleci.com/gh/opendatacube/datacube-k8s-eks/tree/master.svg?style=shield)](https://circleci.com/gh/opendatacube/datacube-k8s-eks/tree/master)

---

# Supported Features

* EKS cluster with PostgreSQL database
* Multi-factor Authentication enforcement for Admin users
* Scale applications based on usage
* Scale cluster to fit application requirements
* Spot instance support
* Send logs to CloudWatch
* Automatically generated domain wildcard certificate for application load balancer
* Optional CloudFront distribution with automatically generated certificates
* Optional WAF application firewall rules for jupyterhub - OWASP Top 10 security risks protection
* Automatically register route53 DNS records
* Inspect cluster metrics using Prometheus and Grafana
* Modules to create IAM roles and users, used by cluster pods
* Module to create cognito auth user pool for application authentication

# Getting started

Follow our [Getting Started Guide](docs/getting_started.md) to deploy your first cluster and learn how to customise your build.

# Documentation

* [Cluster Access](docs/cluster_access.md) - How to add users and configure access
* [Service Account](docs/service_account.md) - Creating a service account to build the infrastructure

# Repository Layout

* cognito - ODC supporting module that creates AWS Cognito user pool for user authentication
* docs - Out of code documentation as above
* examples - Sample Terraform deployments that can be spun-up and destroyed to test the various modules
* odc_eks - Core components required to run an EKS cluster for ODC
* ods_k8s - Kubernetes service pods required to perform Continuous deployment of applications.
  * [Flux](https://www.weave.works/oss/flux/)
  * [Helm](https://helm.sh/)

:warning: Soon to be deprecated :warning:
* odc_role - ODC supporting module that creates IAM role for cluster pods
* odc_user - ODC supporting module that creates IAM user for cluster pods
* .circleci - TFLint CI automation

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->