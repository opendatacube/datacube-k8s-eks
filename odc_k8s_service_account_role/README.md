# Terraform Open Data Cube EKS Module: k8s_service_account_role

The purpose of this module is to provision IAM roles to support service account role based access. 
For more detail read - [Introducing fine-grained IAM roles for service accounts](https://aws.amazon.com/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/) 

---

## Introduction

* Provide fine-grained roles at the pod level rather than the node level
* No need to pass user credentials as long as the application is configured for service account web identity token based access

## Limitation

* Extra role handling logic required to get a temporary credentials using assume role with web identity based session - ideally using boto3 AWS SDK
* Needed a logic to auto refresh session for a long lived service
* Needed a logic to export credentials to support third party tools/library

## Usage

First step is to provision service account role for k8s service account like -

```terraform
module "svc_role_alb_controller" {
  source = "../../../odc_k8s_service_account_role"

  # Default Tags
  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment

  #OIDC
  oidc_arn = local.oidc_arn
  oidc_url = local.oidc_url

  # Additional Tags
  tags = local.tags

  # service account role used in processing namespace
  service_account_role = {
    name                      = "svc-${local.cluster_id}-foo-sa"
    service_account_namespace = "processing"
    service_account_name      = "*"
    policy                    = <<-EOF
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Action": ["S3:ListBucket"],
            "Resource": [
              "arn:aws:s3:::dea-public-data"
            ]
          },
          {
            "Effect": "Allow",
            "Action": ["S3:GetObject"],
            "Resource": [
              "arn:aws:s3:::dea-public-data/*"
            ]
          }
        ]
      }
    EOF
  }
}
```

This role then be used by k8s service-account using `eks.amazonaws.com/role-arn` annotation. 
Alternatively, you can configure service-account and assign a service-account to pod/deployment. 
This will then pass `AWS_ROLE_ARN` and `AWS_WEB_IDENTITY_TOKEN_FILE` environment variables to the pod.
Then configure a pod to assumes the IAM role using `sts:AssumeRoleWithWebIdentity`.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: foo-sa
  namespace: processing
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<account-id>:role/svc-<cluster_id>-foo-sa
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: foo-sa-processing
  namespace: processing
  labels:
    app: foo-sa-processing
spec:
  selector:
    matchLabels:
      app: foo-sa-processing
  template:
    metadata:
      labels:
        app: foo-sa-processing
    spec:
      serviceAccountName: foo-sa
  container:
    ...
```

## Variables

### Inputs
| Name                 | Description                                                                                                 | Type        | Default             | Required |
| ------               | -------------                                                                                               | :----:      | :-----:             | :-----:  |
| owner                | The owner of the environment                                                                                | string      |                     | Yes      |
| namespace            | The unique namespace for the environment, which could be your organization name or abbreviation, e.g. 'odc' | string      |                     | Yes      |
| environment          | The name of the environment - e.g. dev, stage                                                               | string      |                     | Yes      |
| oidc_arn             | The arn of the OpenId connect provider associated with this cluster                                         | string      |                     | Yes      |
| oidc_url             | The url of the OpenId connect provider associated with this cluster                                         | string      |                     | Yes      |
| service_account_role | Specify custom IAM roles that can be used by pods on the k8s cluster                                        | map         | [see example above] | Yes      |
| tags                 | Additional tags - e.g. `map('StackName','XYZ')`                                                             | map(string) | {}                  | No       |

### Outputs
| Name      | Description               | Sensitive   |
| ------    | -------------             | ----------- |
| role_name | Service account role name | false       |
| role_arn  | Service account role ARN  | false       |
