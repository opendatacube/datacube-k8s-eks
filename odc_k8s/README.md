# Terraform Open Data Cube EKS Module: odc_k8s

Terraform ODC supporting module that provision a kubernetes core components on top of Open Data Cube EKS cluster. 

#### Warning

* This is an extension module that is build upon [odc_eks](https://github.com/opendatacube/datacube-k8s-eks/tree/terraform-aws-odc/odc_eks) cluster.

---

## Requirements

[AWS CLI](https://aws.amazon.com/cli/)

[Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

[Helm](https://github.com/kubernetes/helm#install)

[Terraform](https://www.terraform.io/downloads.html)

[Fluxctl](https://docs.fluxcd.io/en/stable/tutorials/get-started.html) -(optional)

## Introduction

The module provisions the following resources:

- Install kubernetes core components - tiller, helm, flux, fluxcloud.
- Optionally creates a AWS CloudWatch log group to collect logs for your cluster.

## Usage

The complete Open Data Cube terraform AWS example is provided for kick start [here](https://github.com/opendatacube/datacube-k8s-eks/tree/terraform-aws-odc/examples/stage).
Copy the example to create your own live repo to setup ODC infrastructure to run [jupyterhub](https://github.com/jupyterhub/zero-to-jupyterhub-k8s) notebook and ODC web services to your own AWS account.

```hcl-terraform
  # Collect Data from odc_eks parent module
  module "odc_k8s" {
    source = "github.com/opendatacube/datacube-k8s-eks//odc_k8s?ref=terraform-aws-odc"
    
    # Default tags + resource labels
    owner           = "odc-owner"
    namespace       = "odc"
    environment     = "stage"
    
    # Additional Tags
    tags = {
      "stack_name" = "odc-stage-cluster"
      "cost_code" = "CC1234"
      "project" = "ODC"
    }
    
    region       = "ap-southeast-2"
    cluster_id   = "odc-stage-cluster"
    
    # Cluster Access Options
    node_roles = {
      "system:node:{{EC2PrivateDNSName}}": data.terraform_remote_state.odc_eks-stage.outputs.node_role_arn
    }
    # Optional: user_roles and users
    # Example:
    # user_roles = {
    #   cluster-admin: <user-role-arn>
    # }
    users = {
      eks-deployer: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/eks-deployer"
    }
    
    # Database
    store_db_creds    = false
    
    # Setup Flux/FluxCloud
    flux_enabled = true
    flux_git_repo_url = "git@github.com:opendatacube/flux-odc-sample.git"
    flux_git_branch = "master"
    flux_git_path = "flux"
    flux_git_label = "flux-sync"
    
    fluxcloud_enabled = true
    fluxcloud_slack_url = "<slack-url>"
    fluxcloud_slack_channel = "<slack-channel>"
    fluxcloud_slack_name = "Flux Example Deployer"
    fluxcloud_slack_emoji = ":zoidberg:"
    fluxcloud_github_url = "https://github.com/opendatacube/flux-odc-sample"
    fluxcloud_commit_template = "{{ .VCSLink }}/commits/{{ .Commit }}"
    
    # Cloudwatch Log Group - for fluentd
    cloudwatch_logs_enabled  = true
    cloudwatch_log_group     = "odc-stage-cluster-logs"
    cloudwatch_log_retention = 90
  }
```

## Variables

### Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| owner | The owner of the environment | string | `` | yes |
| namespace | The unique namespace for the environment, which could be your organization name or abbreviation, e.g. 'odc' | string | `` | yes |
| environment | The name of the environment - e.g. dev, stage | string | `` | yes |
| cluster_id | The name of your cluster. Used for the resource naming as identifier | string | `` | yes |
| node_roles | A list of node roles that will be given access to the cluster | map | | Yes |
| user_roles | A list of user roles that will be given access to the cluster | map | {} | No |
| users | A list of users that will be given access to the cluster | map | {} | No |
| db_hostname | DB hostname for coredns config | string | `` | No |
| db_admin_username | Username for the database to store in a default kubernetes secret. Inject through odc_eks terraform output state file | string | `` | No |
| db_admin_password | Password for the database to store in a default kubernetes secret. Inject through odc_eks terraform output state file | string | `` | No |
| store_db_creds | If true, store the db_admin_username and db_admin_password variables in a kubernetes secret | bool | false | No |
| tags | Additional tags - e.g. `map('StackName','XYZ')` | map(string) | {} | no | 