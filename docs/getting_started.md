# Getting Started

## Install Tools

* AWS CLI - required for Terraform and the iam authenticator
  * <https://aws.amazon.com/cli/>
* Kubectl - interact with our kubernetes cluster
  * <https://kubernetes.io/docs/tasks/tools/install-kubectl/>
* AWS IAM Authenticator - manage user access to your cluster
  * <https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html>
* Helm - We use helm to deploy application templates to our cluster
  * <https://github.com/kubernetes/helm#install>
* Terraform - enables us to deploy repeatable infrastructure using declarative configuration files
  * <https://www.terraform.io/downloads.html>

## Setup your environment

In order to create the infrastructure you'll need to configure your aws cli to have security credentials to access to
your account. This can be done using the [Configuring the AWS CLI Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

You'll also need a public Route53 zone so your applications can be accessed externally. This can be configured using
the following guide [A Public Route53 Hosted Zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html)

## Create your live repo

This repo provides ODC terraform modules required to setup an Open Data Cube EKS cluster on AWS platform.

In order to setup ODC infrastructure, you need to create your own live repo showed in `examples/` that contains
`examples/backend_init` and `examples/stage`.

## Create the terraform backend

We store the current state of the infrastructure on an AWS S3 bucket to ensure terraform knows what infrastructure it
has created, even if something happens to the machine.

We also use a simple dynamodb table as a lock to ensure multiple people can't make a deployment at the same time.

To set up this infrastructure, you'll need to adjust the following variables in `examples/backend_init/variables.tf`

| Variable      | Description                                                                     | Default            |
| :---          | :---                                                                            | ---                |
| `region`      | The AWS region to provision resources                                           | `"ap-southeast-2"` |
| `owner`       | The owner of the environment                                                    | `"odc-test"`       |
| `namespace`   | The name used for creation of backend resources like the terraform state bucket | `"odc-test"`       |
| `environment` | The name of the environment - e.g. `dev`, `stage`, `prod`                       | `"stage"`          |

The `namespace` and `environment` combination needs to be unique for your project.

Run these commands in order to create the required infrastructure to store terraform state:

```shell script
  cd examples/backend_init
  terraform init
  terraform plan
  terraform apply
```

Terraform will create the required resources, at the end you'll see: 

> `Apply complete!`


```properties
tf-state-bucket="${namespace}-${environment}-backend-tfstate"
dynamodb_table="${namespace}-${environment}-backend-terraform-lock"
```

Congratulations you're all setup and ready to build your first cluster!

## Creating your first cluster

Refer to the document under `examples/README.md` [here](../examples/README.md) to setup a new ODC cluster environment.
