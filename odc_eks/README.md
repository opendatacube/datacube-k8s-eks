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

### Module Extensions(Optional Components)
- Setup a AWS CloudFront Distribution to support Open Data Cube web services
- Setup AWS WAF for web application security for web application.
- Issue a domain certificate using AWS Certificate Manager. It uses Route53 to validate certificate. 

### WAF Important Consideration
- If you are using WAF for `jupyterhub` setup, make sure to enable `waf_enable_url_whitelist_string_match_set` - 
string match filter for allow users to compose and save jupyterhub `notebooks` that contains rich HTML contents.
- Pass additional settings to support WAF for jupyterhub - 
```hcl-terraform
  waf_enable_url_whitelist_string_match_set = true
  waf_url_whitelist_uri_prefix              = "/user"
  waf_url_whitelist_url_host                = "app.example.domain.com"
```

## Usage

The complete Open Data Cube terraform AWS example is provided for kick start [here](https://github.com/opendatacube/datacube-k8s-eks/tree/master/examples/stage).
Copy the example to create your own live repo to setup ODC infrastructure to run [jupyterhub](https://github.com/jupyterhub/zero-to-jupyterhub-k8s) notebook and ODC web services to your own AWS account.

```hcl-terraform
  module "odc_eks" {
    source = "github.com/opendatacube/datacube-k8s-eks//odc_eks?ref=master"
    
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
    min_spot_nodes = 0
    max_spot_nodes = 4
    
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
    # Additional setting required to setup URL whitelist string match filter
    # Recommanded if WAF is enabled for `jupyterhub` setup
    waf_enable_url_whitelist_string_match_set = true
    waf_url_whitelist_uri_prefix              = "/user"
    waf_url_whitelist_url_host                = app.example.domain.com
  }
```

## Variables

### Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| owner | The owner of the environment | string |  | yes |
| namespace | The unique namespace for the environment, which could be your organization name or abbreviation, e.g. 'odc' | string |  | yes |
| environment | The name of the environment - e.g. dev, stage | string |  | yes |
| region | The AWS region to provision resources | string | "ap-southeast-2" | No |
| cluster_id | The name of your cluster. Used for the resource naming as identifier | string |  | yes |
| cluster_version | EKS Cluster version to use | string |  | Yes |
| admin_access_CIDRs | Locks ssh and api access to these IPs | map(string) | {} | No |
| user_custom_policy | The IAM custom policy to create and attach to EKS user role | string | "" | No |
| user_additional_policy_arn | The list of pre-defined IAM policy required to EKS user role | list(string) | [] | No |
| domain_name | The domain name to be used by applications deployed to the cluster and using ingress | string |  | Yes |
| db_name | The name of your RDS database | string |  | Yes |
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
| default_worker_instance_type | The Worker instance type that the cluster nodes will run, for production we recommend something with a good network, as most of the Open Data Cube work is I/O bound, For example r4.4xlarge or c5n.4xlarge | string |  | Yes |
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

### Input - Extensions

#### CloudFront Distribution
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cf_enable | Whether the cloudfront distribution should be created | bool | false | No |
| cf_dns_record | The domain used by point to cloudfront | string | "" | No |
| cf_origin_dns_record | The domain of load balancer that will be created by kubernetes | string | "" | No |
| cf_custom_aliases | Extra CNAMEs (alternate domain names), if any, for this distribution | list(string) | [] | No |
| cf_certificate_create | Whether to create a certificate for cloudfront distribution | bool | true | No | 
| cf_certificate_arn | Provide your own us-east-1 certificate ARN when setting additional aliases. Needed when `cf_certificate_create` set to false | string | "" | No |
| cf_log_bucket_create | Whether to create cloudfront log bucket | bool | false | No |
| cf_log_bucket | Name of your cloudfront log bucket | string | "" | No |
| cf_origin_protocol_policy | Which protocol is used to connect to origin, http-only, https-only, match-viewer | string | "http-only" | No |
| cf_origin_timeout | The time cloudfront will wait for a response | number | 60 | No |
| cf_default_allowed_methods | Controls which HTTP methods CloudFront processes and forwards to your Amazon S3 bucket or your custom origin | list(string) | ["GET", "HEAD", "POST", "OPTIONS", "PUT", "PATCH", "DELETE"] | No |
| cf_default_cached_methods | Controls whether CloudFront caches the response to requests using the specified HTTP methods | list(string) | ["GET", "HEAD"] |
| cf_min_ttl | The minimum amount of time that you want objects to stay in CloudFront caches before CloudFront queries your origin to see whether the object has been updated | bool | 0 | No |
| cf_max_ttl | The maximum amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request to your origin to determine whether the object has been updated | number | 31536000 | No |
| cf_default_ttl | The default amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request in the absence of an Cache-Control max-age or Expires header | number | 86400 | No |
| cf_price_class | The Price class for this distribution, can be PriceClass_100, PriceClass_200 or PriceClass_All | string | "PriceClass_All" | No |

#### WAF
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| waf_enable | Whether the WAF resources should be created | bool | false | No |
| waf_target_scope | Valid values are `global` and `regional`. This variable value should be set to regional if integrate with ALBs | string | "regional" | No |
| waf_log_bucket_create | Whether to create WAF log bucket | bool | false | No |
| waf_log_bucket | The name of the bucket to store WAF logs in | string | "" | No |
| waf_max_expected_body_size | Maximum number of bytes allowed in the body of the request | string | "536870912" | No |
| waf_firehose_buffer_size | Buffer incoming data to the specified size, in MBs, before delivering it to the destination. Valid value is between 64-128 | string | "128" | No |
| waf_firehose_buffer_interval | Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination. Valid value is between 60-900 | string | "900" | No |
| waf_disable_03_uri_url_decode | Disable the 'URI contains a cross-site scripting threat after decoding as URL.' filter | bool | false | No |
| waf_disable_03_uri_html_decode | Disable the 'URI contains a cross-site scripting threat after decoding as HTML tags.' filter | bool | false | No |
| waf_disable_03_query_string_url_decode | Disable the 'Query string contains a cross-site scripting threat after decoding as URL.' filter | bool | false | No |
| waf_disable_03_query_string_html_decode | Disable the 'Query string contains a cross-site scripting threat after decoding as HTML tags.' filter | bool | false | No |
| waf_disable_03_body_url_decode | Disable the 'Body contains a cross-site scripting threat after decoding as URL.' filter | bool | false | No |
| waf_disable_03_body_html_decode | Disable the 'Body contains a cross-site scripting threat after decoding as HTML tags.' filter | bool | false | No |
| waf_disable_03_cookie_url_decode | Disable the 'Header cookie contains a cross-site scripting threat after decoding as URL.' filter | bool | false | No |
| waf_disable_03_cookie_html_decode | Disable the 'Header 'cookie' contains a cross-site scripting threat after decoding as HTML tags.' filter | bool | false | No |
| waf_disable_04_uri_contains_previous_dir_after_url_decode | Disable the 'URI contains: '../' after decoding as URL.' filter | bool | false | No |
| waf_disable_04_uri_contains_previous_dir_after_html_decode | Disable the 'URI contains: '../' after decoding as HTML tags.' filter | bool | false | No |
| waf_disable_04_query_string_contains_previous_dir_after_url_decode | Disable the 'Query string contains: '../' after decoding as URL.' filter | bool | false | No |
| waf_disable_04_query_string_contains_previous_dir_after_html_decode | Disable the 'Query string contains: '../' after decoding as HTML tags.' filter | bool | false | No |
| waf_disable_04_uri_contains_url_path_after_url_decode | Disable the 'URI contains: '://' after decoding as URL.' filter | bool | false | No |
| waf_disable_04_uri_contains_url_path_after_html_decode | Disable the 'URI contains: '://' after decoding as HTML tags.' filter | bool | false | No |
| waf_disable_04_query_string_contains_url_path_after_url_decode | Disable the 'Query string contains: '://' after decoding as URL.' filter | bool | false | No |
| waf_disable_04_query_string_contains_url_path_after_html_decode | Disable the 'Query string contains: '://' after decoding as HTML tags.' filter | bool | false | No |
| waf_enable_url_whitelist_string_match_set | Enable the 'URL whitelisting' filter. If enabled, provide values for `url_whitelist_uri_prefix` and `url_whitelist_url_host` | bool | `false` | No |
| waf_url_whitelist_uri_prefix | URI prefix for URL whitelisting. Required if `enable_url_whitelist_string_match_set` is set to `true` | string | `""` | Yes |
| waf_url_whitelist_url_host | Host for URL whitelisting. Required if `enable_url_whitelist_string_match_set` is set to `true` | string | `""` | Yes |

#### ACM
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| create_certificate | Whether to create wildcard certificate for given domain | bool | false | No |
