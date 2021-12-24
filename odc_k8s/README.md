# Terraform Open Data Cube EKS Module: odc_k8s

Terraform ODC supporting module that provision a kubernetes core components on top of Open Data Cube EKS cluster.

#### Warning

* This is an extension module that is build upon [odc_eks](https://github.com/opendatacube/datacube-k8s-eks/tree/master/odc_eks) cluster.

---

## Requirements

[AWS CLI](https://aws.amazon.com/cli/)

[Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

[Helm](https://github.com/kubernetes/helm#install)

[Terraform](https://www.terraform.io/downloads.html)

[Fluxctl](https://docs.fluxcd.io/en/stable/tutorials/get-started.html) -(optional)

## Introduction

The module provisions the following resources:

- Install kubernetes core components - helm, flux, fluxcloud.
- Optionally creates a AWS CloudWatch log group to collect logs for your cluster.
- Setup `aws-auth` ConfigMap settings for user/role based cluster access.

## Manage Cluster Access

When you create an Amazon EKS cluster, the IAM entity user or role, such as a federated user that creates the cluster,
is automatically granted `system:masters` permissions in the cluster's RBAC configuration. To grant additional AWS users
or roles the ability to interact with your cluster, you must edit the `aws-auth` ConfigMap within Kubernetes.

### MapRoles config

**Option 1: Must provide `node_roles` (for worker node group access) and optional `user_roles` (role based user access) params**
```terraform
node_roles = {
  "system:node:{{EC2PrivateDNSName}}": data.terraform_remote_state.odc_eks-stage.outputs.node_role_arn
}
# NOTE: roles are assigns to `system:masters` group
user_roles = {
  cluster-admin: "<IAM-role-arn>"
}
```

**Option 2: provide a `role_config_template` param**
```terraform
role_config_template = "<renderd aws-auth MapRoles config template>"
```

### MapUsers config

**Option 1: provide `users` param**
```terraform
# NOTE: users are assigns to `system:masters` group
users = {
  eks-deployer: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/eks-deployer"
}
```

**Option 2: provide a `user_config_template` param**
```terraform
user_config_template = "<renderd aws-auth MaapUsers config template>"
```

### IAM roles for Kubernetes service accounts
With the introduction of IAM roles for services accounts (IRSA), you can create an IAM role specific to your workload’s requirement in Kubernetes.
This also enables the security principle of least privilege by creating fine grained roles at a pod level instead of node level.
The IAM roles for service accounts feature is available on new Amazon EKS Kubernetes version 1.14 and later clusters.
For more detail read - [Introducing fine-grained IAM roles for service accounts](https://aws.amazon.com/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/)


## Usage

The complete Open Data Cube terraform AWS example is provided for kick start [here](https://github.com/opendatacube/datacube-k8s-eks/tree/master/examples/stage).
Copy the example to create your own live repo to setup ODC infrastructure to run [jupyterhub](https://github.com/jupyterhub/zero-to-jupyterhub-k8s) notebook and ODC web services to your own AWS account.

```terraform
# Collect Data from odc_eks parent module
module "odc_k8s" {
  source = "github.com/opendatacube/datacube-k8s-eks//odc_k8s?ref=master"

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
  flux_registry_ecr = {
    regions    = []               # Restrict ECR scanning to these AWS regions
    includeIds = []               # Restrict ECR scanning to these AWS account IDs
    excludeIds = ["602401143452"] # Restrict ECR scanning to exclude these AWS account IDs. Default resticted to EKS system account
  }

  # Cloudwatch Log Group - for fluentd
  cloudwatch_logs_enabled  = true
  cloudwatch_log_group     = "odc-stage-cluster-logs"
  cloudwatch_log_retention = 90
}
```

## Variables

### Inputs
| Name                 | Description                                                                                                           | Type        | Default | Required |
| ------               | -------------                                                                                                         | :----:      | :-----: | :-----:  |
| owner                | The owner of the environment                                                                                          | string      |         | yes      |
| namespace            | The unique namespace for the environment, which could be your organization name or abbreviation, e.g. 'odc'           | string      |         | yes      |
| environment          | The name of the environment - e.g. dev, stage                                                                         | string      |         | yes      |
| cluster_id           | The name of your cluster. Used for the resource naming as identifier                                                  | string      |         | yes      |
| node_roles           | A list of node roles that will be given access to the cluster                                                         | map         | {}      | No       |
| user_roles           | A list of user roles that will be given access to the cluster                                                         | map         | {}      | No       |
| users                | A list of users that will be given access to the cluster                                                              | map         | {}      | No       |
| role_config_template | aws-auth MapRoles config template                                                                                     | string      | ""      | No       |
| user_config_template | aws-auth MapRoles config template                                                                                     | string      | ""      | No       |
| db_hostname          | DB hostname for coredns config                                                                                        | string      | ""      | No       |
| db_admin_username    | Username for the database to store in a default kubernetes secret. Inject through odc_eks terraform output state file | string      | ""      | No       |
| db_admin_password    | Password for the database to store in a default kubernetes secret. Inject through odc_eks terraform output state file | string      | ""      | No       |
| store_db_creds       | If true, store the db_admin_username and db_admin_password variables in a kubernetes secret                           | bool        | false   | No       |
| tags                 | Additional tags - e.g. `map('StackName','XYZ')`                                                                       | map(string) | {}      | no       |

### Inputs - FluxCD
| Name                         | Description                                                                                                     | Type                                                                           | Default                                                  | Required |
|------------------------------|-----------------------------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------:|:--------------------------------------------------------:|:--------:|
| flux_enabled                 | Flag to enable flux helm release                                                                                | bool                                                                           | false                                                    | No       |
| flux_version                 | Flux helm release version                                                                                       | string                                                                         | "1.3.0"                                                  | No       |
| flux_git_repo_url            | URL pointing to the git repository that flux will monitor and commit to                                         | string                                                                         | ""                                                       | No       |
| flux_git_branch              | Branch of the specified git repository to monitor and commit to                                                 | string                                                                         | ""                                                       | No       |
| flux_git_path                | Relative path inside specified git repository to search for manifest files                                      | string                                                                         | ""                                                       | No       |
| flux_git_label               | Label prefix that is used to track flux syncing inside the git repository                                       | string                                                                         | "flux-sync"                                              | No       |
| flux_git_timeout             | Duration after which git operations will timeout                                                                | string                                                                         | "20s"                                                    | No       |
| flux_additional_args         | Use additional arg for connect flux to fluxcloud. Syntext: --connect=ws://fluxcloud                             | string                                                                         | ""                                                       | No       |
| flux_registry_exclude_images | comma separated string lists of registry images to exclud from flux auto release: docker.io/*,index.docker.io/* | string                                                                         | ""                                                       | No       |
| flux_helm_operator_version   | Flux helm-operator release version                                                                              | string                                                                         | "1.0.1"                                                  | No       |
| flux_registry_ecr            | Use flux_registry_ecr for fluxcd ecr configuration                                                              | object({regions=list(string) includeIds=list(string) excludeIds=list(string)}) | { regions=[] includeIds=[] excludeIds=["602401143452"] } | No       |
| flux_service_account_arn     | provide flux OIDC service account role arn                                                                      | string                                                                         | ""                                                       | No       |
| flux_monitoring              | If true, enable prometheus metrics                                                                              | false                                                                          | No                                                       |          |
| enabled_helm_versions        | Helm options to support release versions. Valid values: `"v2"`/`"v3"`/`"v2\\,v3"`                               | string                                                                         | "v2\\,v3"                                                | No       |

### Inputs - FluxCloud

| Name                      | Description                                                               | Type   | Default                               | Required |
| ------                    | -------------                                                             | :----: | :-----:                               | :-----:  |
| fluxcloud_enabled         | Flag to deploy fluxcloud - used to notify flux deployment to slack        | bool   | false                                 | No       |
| fluxcloud_slack_url       | Slack webhook URL for fluxcloud to use                                    | string | ""                                    | No       |
| fluxcloud_slack_channel   | Slack channel for fluxcloud to use                                        | string | ""                                    | No       |
| fluxcloud_slack_name      | Slack name for fluxcloud to post under                                    | string | ""                                    | No       |
| fluxcloud_slack_emoji     | Slack emoji for fluxcloud to post under                                   | string | ""                                    | No       |
| fluxcloud_github_url      | VCS URL for fluxcloud links in messages, does not have to be a GitHub URL | string | ""                                    | No       |
| fluxcloud_commit_template | VCS template for fluxcloud links in messages, default is for GitHub       | string | "{{ .VCSLink }}/commit/{{ .Commit }}" | No       |
