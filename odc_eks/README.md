# Terraform Open Data Cube EKS Module: odc_eks

Terraform module designed to provision an Open Data Cube EKS cluster on AWS.
---

## Requirements

[AWS CLI](https://aws.amazon.com/cli/)

[Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

[Helm](https://github.com/kubernetes/helm#install)

[Terraform](https://www.terraform.io/downloads.html)

[Fluxctl](https://docs.fluxcd.io/en/stable/tutorials/get-started.html) -(optional)

## Introduction

The module provisions the following resources:

- Creates VPC resources using [terraform-aws-vpc](https://github.com/terraform-aws-modules/terraform-aws-vpc) module.
- Setup a new RDS instance with PostgreSQL database. Provide a snapshot ID to create the new RDS instance from existing RDS instance.\n
This is useful if migration is being performed to deploy a new infrastructure with pre-existing data indexed.

### Optional Components
- Setup a AWS CloudFront Distribution to support Open Data Cube web services
- Setup AWS WAF for web application security for web application.
- Issue a domain certificate using AWS Certificate Manager. It uses Route53 to validate certificate. 

## Usage

The complete Open Data Cube terraform AWS example is provided for kick start [here](https://github.com/opendatacube/datacube-k8s-eks/tree/terraform-aws-odc/examples/stage).
Copy the example to create your own live repo to setup ODC infrastructure to run [jupyterhub](https://github.com/jupyterhub/zero-to-jupyterhub-k8s) notebook and ODC web services to your own AWS account.

```hcl-terraform
  module "odc_eks" {
    source = "github.com/opendatacube/datacube-k8s-eks//odc_eks?ref=terraform-aws-odc"
    
    # Cluster config
    region          = "ap-southeast-2"
    cluster_id      = "odc-stage-cluster"   # optional - if not provided it uses odc_eks_label defined in the module.
    cluster_version = 1.14
    
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
    
    domain_name = "example.domain.com"
    
    # ACM - used by ALB
    create_certificate  = true
    
    # DB config
    db_name = "odc"
    db_engine_version = { postgres = "11.5" }
    db_multi_az = false
    
    # System node instances
    default_worker_instance_type = "t3.medium"
    spot_nodes_enabled = true
    min_nodes = 2
    max_nodes = 4
    
    # Cloudfront CDN
    cf_enable                 = true
    cf_dns_record             = "odc"
    cf_origin_dns_record      = "cached-alb"
    cf_custom_aliases         = []
    cf_certificate_create     = true
    cf_origin_protocol_policy = "https-only"
    cf_log_bucket_create      = true
    cf_log_bucket             = "odc-stage-cloudfront-logs"
    
    # WAF
    waf_enable             = true
    waf_target_scope       = "regional"
    waf_log_bucket         = "odc-stage-waf-logs"
  }
```

## Variables

### Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| owner | The owner of the environment | string | `` | yes |
| namespace | The unique namespace for the environment, which could be your organization name or abbreviation, e.g. 'odc' | string | `` | yes |
| environment | The name of the environment - e.g. dev, stage | string | `` | yes |
| region | The AWS region to provision resources | string | "ap-southeast-2" | No |
| cluster_id | The name of your cluster. Used for the resource naming as identifier | string | `` | yes |
| cluster_version | EKS Cluster version to use | string | `` | Yes |
| admin_access_CIDRs | Locks ssh and api access to these IPs | map(string) | {} | No |
| user_custom_policy | The IAM custom policy to create and attach to EKS user role | string | `` | No |
| user_additional_policy_arn | The list of pre-defined IAM policy required to EKS user role | list(string) | [] | No |
| domain_name | The domain name to be used by applications deployed to the cluster and using ingress | string | `` | Yes |
| create_certificate | Whether to create certificate for given domain | bool | false | Yes |
| db_name | The name of your RDS database | string | `` | Yes |
| db_multi_az | If set to true your RDS will have read replicas in other Availability Zones, recommended for production environments to ensure the system will tolerate failure of an Availability Zone | bool | false | No |
| db_storage | RDS storage size in GB. If this is increased it cannot be decreased | string | "180" | No |
| db_max_storage | Enables storage autoscaling up to this amount, must be equal to or greater than db_storage, if this value is 0, storage autoscaling is disabled | string | "0" | No
| db_extra_sg | Enables an extra security group to access the RDS, this is potentially useful if you wish to use lambda's or extra EC2 instances to perform database admin tasks | string | "" | No |
| db_engine_version | Explicitly sets engine specific version for the database used | map | default = { postgres = "9.6.11" } | No |
| db_migrate_snapshot | Snapshot ID for database creation if a migration is being performed to deploy new infrastructure | string | "" | No |
| vpc_cidr | The network CIDR you wish to use for this VPC. Default is set to 10.0.0.0/16 for most use-cases | string | "10.0.0.0/16" | No |
| public_subnet_cidrs | List of public cidrs, for all available availability zones. Used by VPC module to setup public subnets | list(string) | ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"] | No |
| private_subnet_cidrs | List of private cidrs, for all available availability zones. Used by VPC module to setup private subnets | list(string) | ["10.0.32.0/19", "10.0.64.0/19", "10.0.96.0/19"] | No |
| database_subnet_cidrs | List of database cidrs, for all available availability zones. Used by VPC module to setup database subnets | list(string) | ["10.0.20.0/22", "10.0.24.0/22", "10.0.28.0/22"] | No |
| enable_ec2_ssm | Enables the IAM policy required for AWS EC2 System Manager in the EKS Node IAM role created | bool | true | No |
| ami_image_id | This variable can be used to deploy a patched / customised version of the Amazon EKS image | string | "" | No |
| node_group_name | Autoscaling node group name. This name is used to tag instances and ASGs | string | "eks" | No |
| default_worker_instance_type | The Worker instance type that the cluster nodes will run, for production we recommend something with a good network, as most of the Open Data Cube work is I/O bound, For example r4.4xlarge or c5n.4xlarge | string | `` | Yes |
| min_nodes | The minimum number of on-demand nodes to run | number | 0 | No |
| desired_nodes | Desired number of nodes only used when first launching the cluster afterwards you should scale with something like cluster-autoscaler | number | 0 | No |
| max_nodes | Max number of nodes you want to run, useful for controlling max cost of the cluster | number | 0 | No |
| spot_nodes_enabled | Creates a second set of Autoscaling groups (one per AZ) that are configured to run Spot instances, these instances are cheaper but can be removed any-time. Useful for fault tolerant processing work | bool | false | No | 
| min_spot_nodes | The minimum number of spot nodes to run | bool | 0 | No |
| max_spot_nodes | Max number of spot you want to run, useful for controlling max cost of the cluster | number | 0 | No |
| max_spot_price | The max in USD you want to pay for each spot instance per hour. Check market price for you instance type to set its value | string | "0.40" | No |
| volume_size | The Disk size for your on-demand nodes. If you're getting pods evicted for ephemeral storage saving, you should increase this. | number | 20 | No |
| spot_volume_size | The Disk size for your spot nodes. If you're getting pods evicted for ephemeral storage saving, you should increase this. | number | 20 | No |
| extra_userdata | Additional EC2 user data commands that will be passed to EKS nodes | string | <<USERDATA echo "" USERDATA | No |
| tags | Additional tags - e.g. `map('StackName','XYZ')` | map(string) | {} | no |

### Outputs
| Name | Description | Sensitive |
|------|-------------|-----------|
| kubeconfig | EKS Cluster kubeconfig | true |
| cluster_id | EKS cluster ID | false |
| cluster_arn | EKS cluster ARN | false |
| region | AWS region used by for environment setup | false |
| domain_name | The domain name to be used by applications deployed to the cluster and using ingress | false |
| owner | The owner of the environment | false |
| namespace | The unique namespace for the environment | false |
| environment | The name of the environment | false |
| db_hostname | The RDS instance hostname | false |
| db_admin_username | The RDS instance master username | true |
| db_admin_password | The RDS instance master user password | true |
| db_name | Name of the default database on RDS instance creation | false |
| node_role_arn | IAM role ARN for EKS work node group | false |
| node_security_group | security group for EKS work node group | false |
| ami_image_id | AMI ID used for worker EC2 instances | false |
| certificate_arn | Certificate ARN | false |