# Getting Started

## Install AWS CLI

The AWS cli is required for using Terraform and the iam authenticator, it's good to have around anyway! [AWS CLI](https://aws.amazon.com/cli/)

## Install Kubectl

In order to interact with our kubernetes cluster we'll need to install the [Kubectl CLI tool](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

You should also install the amazon authenticator to manage user access to your cluster [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)

## Install Helm

We use helm to deploy application templates to our cluster [Helm](https://github.com/kubernetes/helm#install)

## Install terraform

Terraform enables us to deploy repeatable infrastructure using declarative configuration files [Terraform](https://www.terraform.io/downloads.html)

## Setup your environment

In order to create the infrastructure you'll need to configure your aws cli to have security credentials to access to your account. This can be done using the [Configuring the AWS CLI Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

You'll also need a public Route53 zone so your applications can be accessed externally. This can be configured using the following guide [A Public Route53 Hosted Zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html)

## Create your a live repo

This repo provides odc terraform modules require to setup an Open Data Cube EKS cluster on AWS platform. 

In order to setup odc infrastructure, you need to create a your own live repo showed in `examples/` that contains `examples/backend_init` and `examples/stage`.

## Create the terraform backend

We store the current state of the infrastructure on an AWS S3 bucket to ensure terraform knows what infrastructure it has created, even if something happens to the machine. We also use a simple dynamodb table as a lock to ensure multiple people can't make a deployment at the same time.

To set up this infrastructure, if you'll need to adjust this variables - `region`, `owner`, `namespace` and `environment`. The backend id will need to be unique to your project.

Run this command to create the required infrastructure to store terraform state:

```shell script
  cd examples/backend_init
  terraform init
  terraform plan
  terraform apply
```

Terraform will create the required resources, at the end you'll see: 

> Apply complete!


```properties
tf-state-bucket="${namespace}-${environment}-backend-tfstate"
dynamodb_table="${namespace}-${environment}-backend-terraform-lock"
```

Congratulations you're all setup and ready to build your first cluster!

## Creating your first cluster

Refer to the document under `examples/README.md` [here](../examples/README.md) to setup a new ODC cluster environment.
