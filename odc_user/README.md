# Terraform Open Data Cube EKS Supporting Module: odc_role

Terraform ODC supporting module that creates IAM user for cluster pods with provided JSON IAM polices documents.

#### Warning

* Create a ODC cluster environment using [odc_eks](https://github.com/opendatacube/datacube-k8s-eks/tree/master/odc_eks) and [odc_k8s](https://github.com/opendatacube/datacube-k8s-eks/tree/master/odc_k8s) first.

---

## Requirements

[AWS CLI](https://aws.amazon.com/cli/)

[Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

[Helm](https://github.com/kubernetes/helm#install)

[Terraform](https://www.terraform.io/downloads.html)

[Fluxctl](https://docs.fluxcd.io/en/stable/tutorials/get-started.html) - (optional)

## Usage

The complete Open Data Cube terraform AWS example is provided for kick start [here](https://github.com/opendatacube/datacube-k8s-eks/tree/master/examples/stage).
Copy the example to create your own live repo to setup ODC infrastructure to run [jupyterhub](https://github.com/jupyterhub/zero-to-jupyterhub-k8s) notebook and ODC web services to your own AWS account.

```hcl-terraform
  module "odc_user" {
    source = "github.com/opendatacube/datacube-k8s-eks//odc_role?ref=master"
    
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
    
    user = {
      name = "svc-odc-stage-user"
      policy = <<-EOF
      {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Effect": "Allow",
              "Action": [
                  "S3:ListBucket"
              ],
              "Resource": [
                "arn:aws:s3:::dea-public-data"
              ]
            },
            {
              "Effect": "Allow",
              "Action": [
                  "S3:GetObject"
              ],
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

## Variables

### Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| owner | The owner of the environment | string |  | yes |
| namespace | The unique namespace for the environment, which could be your organization name or abbreviation, e.g. 'odc' | string |  | yes |
| environment | The name of the environment - e.g. dev, stage | string |  | yes |
| user | Provision a role that can be used by cluster pods | map | {} | yes |
| tags | Additional tags - e.g. `map('StackName','XYZ')` | map(string) | {} | no |

### Outputs
| Name | Description | Sensitive |
|------|-------------|-----------|
| id | User Access ID | true |
| secret | User Secret Access Key | true |