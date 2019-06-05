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

## Install make (Optional)

We use [make](https://www.gnu.org/software/make/) to simplify running scripts in our environment, if you don't want to use it you can just run the scripts directly

## Setup your environment

In order to create the infrastructure you'll need to configure your aws cli to have security credentials to access to your account. This can be done using the [Configuring the AWS CLI Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

You'll also need a public Route53 zone so your applications can be accessed externally. This can be configured using the following guide [A Public Route53 Hosted Zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html)

## Clone the repo

On your command line you'll need to run this to get a copy of the codebase

```bash
git clone git@github.com:opendatacube/datacube-k8s-eks.git
```

then change directory into datacube-k8s-eks to run the following commands.

## Create the terraform backend

We store the current state of the infrastructure on an AWS S3 bucket to ensure terraform knows what infrastructure it has created, even if something happens to the machine. We also use a simple dynamodb table as a lock to ensure multiple people can't make a deployment at the same time.

To set up this infrastructure we run a simple make command, if you're running this in a different aws region you'll need to adjust this variable. The backend id will need to be unique to your project.

Run this command to create the required infrastructure to store terraform state:

```bash
make create-backend region=ap-southeast-2 backend=my-unique-name
```

Terraform will create the required resources, at the end you'll see: 

> Apply complete!

Now if you edit [examples/quickstart/workspaces/datakube-dev/backend.cfg](../examples/quickstart/workspaces/datakube-dev/backend.cfg) you'll see the following:

```properties
bucket="${backend}-tfstate"
key="${backend}/terraform.tfstate"
region="ap-southeast-2"
dynamodb_table="${backend}-terraform-lock"
```

replace the `${backend}` bits with the value you passed to backend earlier and save the file. If you changed the region earlier, you'll need to set that too. For example:

```properties
bucket="my-unique-name-tfstate"
key="my-unique-name/terraform.tfstate"
region="ap-southeast-2"
dynamodb_table="my-unique-name-terraform-lock"
```

Congratulations you're all setup and ready to build your first cluster!

## Creating your first cluster

We have an example cluster definition in the quickstart folder [examples/quickstart/workspaces/terraform.tfvars](../examples/quickstart/workspaces/terraform.tfvars)

```properties
# Cluster config
owner = "datakube-owner"

cluster_name = "dev-eks-datacube"

admin_access_CIDRs = {
  "Everywhere" = "0.0.0.0/0"
}

# Worker instances
default_worker_instance_type = "m4.large"

spot_nodes_enabled = false

min_nodes_per_az = 1

desired_nodes_per_az = 1

max_nodes_per_az = 2

max_spot_price = "0.4"

# Database config

db_multi_az = false

# Addons - Kubernetes logs to cloudwatch

cloudwatch_logs_enabled = false

cloudwatch_log_group = "datakube"

cloudwatch_log_retention = 90

alb_ingress_enabled = true
```

This definition will create a basic kubernetes cluster with 3 nodes (1 per Availability Zone) with a PostgreSQL RDS server in a single availability zone.

You can deploy it using 

```bash
make apply workspace=datakube-dev path=$(pwd)/examples/quickstart/workspaces
```

after about 15-20 minutes you'll have a running Kubernetes cluster that you can interact with. Run kubectl to see what is deployed in your cluster.
```bash
kubectl get pods --all-namespaces
```

# Next Steps

You can enable more addons by adding them to your `terraform.tfvars` file and running `make apply` again

Create a database for your datacube apps

```bash
make create-db name=ows
```

You can then index some data into your datacube using the predefined template [jobs/index-s3.yaml](../jobs/index-s3.yaml)

```bash
make run-index template=index-s3.yaml
```

Follow our [additional users guide](./additonal_users.md) to add more administrators to the cluster

# Tear it down

When you're done with your cluster you can destroy it by running 

```bash
make destroy  workspace=datakube-dev path=$(pwd)/examples/quickstart/workspaces
```

N.B. This won't delete your terraform backend
