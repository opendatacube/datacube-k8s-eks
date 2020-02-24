# Terraform Open Data Cube EKS Supporting Module: cognito

Terraform ODC supporting module that creates AWS Cognito user pool for sandbox user authentication.

#### Warning

* Create a ODC cluster environment using [odc_eks](https://github.com/opendatacube/datacube-k8s-eks/tree/terraform-aws-odc/odc_eks) and [odc_k8s](https://github.com/opendatacube/datacube-k8s-eks/tree/terraform-aws-odc/odc_k8s) first.
---

## Requirements

[AWS CLI](https://aws.amazon.com/cli/)

[Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

[Helm](https://github.com/kubernetes/helm#install)

[Terraform](https://www.terraform.io/downloads.html)

[Fluxctl](https://docs.fluxcd.io/en/stable/tutorials/get-started.html) - (optional)

## Usage

The complete Open Data Cube terraform AWS example is provided for kick start [here](https://github.com/opendatacube/datacube-k8s-eks/tree/terraform-aws-odc/examples/stage).
Copy the example to create your own live repo to setup ODC infrastructure to run [jupyterhub](https://github.com/jupyterhub/zero-to-jupyterhub-k8s) notebook and ODC web services to your own AWS account.

```hcl-terraform
  module "cognito_auth_jhub" {
    source = "github.com/opendatacube/datacube-k8s-eks//cognito?ref=terraform-aws-odc"
    
    auto_verify = true
    user_pool_name       = "odc-stage-cluster-jhub-userpool"
    user_pool_domain     = "odc-stage-cluster-jhub-auth"
    callback_url         = "https://app.example.domain.com/oauth_callback"
    user_groups = [
      {
          name        = "dev-group"
          description = "Group defines Jupyterhub dev users"
          precedence  = 5
      },
      {
          name        = "default-group"
          description = "Group defines Jupyterhub default users"
          precedence  = 10
      }
    ]
    
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
  }
```

## Variables

### Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| owner | The owner of the environment | string | `` | yes |
| namespace | The unique namespace for the environment, which could be your organization name or abbreviation, e.g. 'odc' | string | `` | yes |
| environment | The name of the environment - e.g. dev, stage | string | `` | yes |
| auto_verify | Set to true to allow the user account to be auto verified. False - admin will need to verify | bool | | yes |
| callback_url | The callback url for your application | string | | yes |
| user_pool_name | The cognito user pool name | string | | yes |
| user_pool_domain | The cognito user pool domain | string | | yes |
| user_groups | List of user groups manage by cognito user pool | List | [] | no |
| admin_create_user_config | The configuration for AdminCreateUser requests | map | {} | no |
| admin_create_user_config_allow_admin_create_user_only | Set to True if only the administrator is allowed to create user profiles. Set to False if users can sign themselves up via an app | bool | false | No | 
| admin_create_user_config_unused_account_validity_days | The user account expiration limit, in days, after which the account is no longer usable | number | 0 | No |
| admin_create_user_config_email_message | The message template for email messages. Must contain `{username}` and `{####}` placeholders, for username and temporary password, respectively | string | null | No |
| admin_create_user_config_email_subject | The subject line for email messages | string | null | No |
| email_verification_message | A string representing the email verification message | string | null | No |
| email_verification_subject | A string representing the email verification subject | string | null | No |
| admin_create_user_config_sms_message | The message template for SMS messages. Must contain `{username}` and `{####}` placeholders, for username and temporary password, respectively | string | null | No |
| tags | Additional tags - e.g. `map('StackName','XYZ')` | map(string) | {} | no |

### Outputs
| Name | Description | Sensitive |
|------|-------------|------|
| userpool_id | Cognito user pool ID | true |
| userpool_domain | Cognito user pood domain | false |
| client_id | Cognito user pool client ID | true |
| client_secret | Cognito user pool client secret | true |