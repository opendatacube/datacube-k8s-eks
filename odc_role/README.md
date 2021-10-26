# Terraform Open Data Cube EKS Supporting Module: odc_role

> This is a deprecated module, please use [ODC Kubernetes Service Account Role](../odc_k8s_service_account_role) instead. This module will be removed soon.

Terraform ODC supporting module that creates IAM role for cluster pods with provided JSON IAM polices documents.

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

```terraform
module "odc_role_autoscaler" {
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

  cluster_id = local.cluster_id

  role = {
    name = "odc-stage-autoscaler-role"
    policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DescribeTags",
            "autoscaling:SetDesiredCapacity",
            "autoscaling:TerminateInstanceInAutoScalingGroup",
            "ec2:DescribeLaunchTemplateVersions"
          ],
          "Resource": "*"
        }
      ]
    }
    POLICY
  }
}
```

## Variables

### Inputs
| Name        | Description                                                                                                 | Type        | Default | Required |
| ------      | -------------                                                                                               | :----:      | :-----: | :-----:  |
| owner       | The owner of the environment                                                                                | string      |         | yes      |
| namespace   | The unique namespace for the environment, which could be your organization name or abbreviation, e.g. 'odc' | string      |         | yes      |
| environment | The name of the environment - e.g. dev, stage                                                               | string      |         | yes      |
| cluster_id  | The name of your cluster for role based cluster access - attach to assume role policy                       | string      |         | yes      |
| role        | Provision a role that can be used by cluster pods                                                           | map         | {}      | yes      |
| tags        | Additional tags - e.g. `map('StackName','XYZ')`                                                             | map(string) | {}      | no       |

### Outputs
| Name      | Description   | Sensitive   |
| ------    | ------------- | ----------- |
| role_name | Role Name     | false       |
| role_arn  | Role ARN      | false       |
