# Variables 

This page gives an overview of all possible variables that can be put in a `terraform.tfvars` file


| Variable                                                                                    | Deploy Stage         | Required | Default |
| ------------------------------------------------------------------------------------------- | -------------------- | ---------| ------- |
| [region](#region)                                                                           | Infra, Nodes, Addons | No  | "ap-southeast-2" |
| [owner](#owner)                                                                             | Infra, Nodes, Addons | No  | "Team name" |
| [cluster_name](#cluster_name)                                                               | Infra, Nodes, Addons | No  | "datacube-eks" |
| [cluster_version](#cluster_version)                                                         | Infra                | Yes |  |
| [eks_service_user](#eks_service_user)                                                       | Infra                | No  | "" |
| [admin_access_CIDRs](#admin_access_CIDRs)                                                   | Infra                | No  | {} |
| [users](#users)                                                                             | Infra                | Yes | |
| [user_custom_policy](#user_custom_policy)                                                   | Infra                | No  | "" |
| [user_additional_policy_arn](#user_additional_policy_arn)                                   | Infra                | No  | [] |
| [domain_name](#domain_name)                                                                 | Infra, Addons        | Yes | |
| [cloudfront_log_bucket](#cloudfront_log_bucket)                                             | Infra                | No  | "dea-cloudfront-logs.s3.amazonaws.com" |
| [create_certificate](#create_certificate)                                                   | Infra                | No  | false |
| [db_instance_enabled](#db_instance_enabled)                                                 | Infra                | No  | true |
| [db_name](#db_name)                                                                         | Infra                | No  | "datakube" |
| [db_multi_az](#db_multi_az)                                                                 | Infra                | No  | false |
| [store_db_credentials](#store_db_credentials)                                               | Infra                | No  | false |
| [db_storage](#db_storage)                                                                   | Infra                | No  | 180 |
| [max_db_storage](#max_db_storage)                                                           | Infra                | No  | 0 |
| [db_extra_sg](#db_extra_sg)                                                                 | Infra                | No  | "" |
| [db_engine_version](#db_engine_version)                                                     | Infra                | No  | "11.5" |
| [vpc_cidr](#vpc_cidr)                                                                       | Infra                | No  | "10.0.0.0/16" |
| [public_subnet_cidrs](#public_subnet_cidrs)                                                 | Infra                | No  | ["10.0.0.0/22", "10.0.4.0/22", ["](#"10)10.0.8.0/22"] |
| [private_subnet_cidrs](#private_subnet_cidrs)                                               | Infra                | No  | ["10.0.32.0/19", "10.0.64.0/19", ["](#"10)10.0.96.0/19"] |
| [database_subnet_cidrs](#database_subnet_cidrs)                                             | Infra                | No  | ["10.0.20.0/22", "10.0.24.0/22", ["](#"10)10.0.28.0/22"] |
| [enable_ec2_ssm](#enable_ec2_ssm)                                                           | Infra                | No  | true  |
| [ami_image_id](#ami_image_id)                                                               | Nodes                | No  | "" |
| [node_group_name](#node_group_name)                                                         | Nodes                | No  | "eks" |
| [default_worker_instance_type](#default_worker_instance_type)                               | Nodes                | No  | "" |
| [group_enabled](#group_enabled)                                                             | Nodes                | No  | false |
| [spot_nodes_enabled](#spot_nodes_enabled)                                                   | Nodes                | No  | false |
| [min_nodes](#min_nodes)                                                                     | Nodes                | No  | 0 |
| [desired_nodes](#desired_nodes)                                                             | Nodes                | No  | 0 |
| [max_nodes](#max_nodes)                                                                     | Nodes                | No  | 0 |
| [min_spot_nodes](#min_spot_nodes)                                                           | Nodes                | No  | 0 |
| [max_spot_nodes](#max_spot_nodes)                                                           | Nodes                | No  | 0 |
| [min_nodes_per_az](#min_nodes_per_az)                                                       | Nodes                | No  | 1 |
| [desired_nodes_per_az](#desired_nodes_per_az)                                               | Nodes                | No  | 1 |
| [max_nodes_per_az](#max_nodes_per_az)                                                       | Nodes                | No  | 2 |
| [min_spot_nodes_per_az](#min_spot_nodes_per_az)                                             | Nodes                | No  | 0 |
| [max_spot_nodes_per_az](#max_spot_nodes_per_az)                                             | Nodes                | No  | 2 |
| [max_spot_price](#max_spot_price)                                                           | Nodes                | No  | "0.40" |
| [volume_size](#volume_size)                                                                 | Nodes                | No  | 20 |
| [spot_volume_size](#spot_volume_size)                                                       | Nodes                | No  | 20 |
| [extra_userdata](#extra_userdata)                                                           | Nodes                | No  | <<USERDATA echo "" USERDATA |
| [txt_owner_id](#txt_owner_id)                                                               | Addons               | No  | "AnOwnerId" |
| [autoscaler-scale-down-unneeded-time](#autoscaler-scale-down-unneeded-time)                | Addons               | No  | "10m" |
| [alb_ingress_enabled](#alb_ingress_enabled)                                                 | Addons               | No  | false |
| [cf_enable](#cf_enable)                                                                     | Addons               | No  | false |
| [cf_dns_record](#cf_dns_record)                                                             | Addons               | No  | ows |
| [cf_origin_dns_record](#cf_origin_dns_record)                                               | Addons               | No  | cached-alb |
| [cf_custom_aliases](#cf_custom_aliases)                                                     | Addons               | No  | [] |
| [cf_certificate_arn](#cf_certificate_arn)                                                   | Addons               | No  | "" |
| [cf_certificate_create](#cf_certificate_create)                                             | Addons               | No  | true |
| [cf_log_bucket](#cf_log_bucket)                                                             | Addons               | No  | "" |
| [cf_log_bucket_create](#cf_log_bucket_create)                                               | Addons               | No  | true |
| [cf_origin_protocol_policy](#cf_origin_protocol_policy)                                     | Addons               | No  | http-only |
| [cf_origin_timeout](#cf_origin_timeout)                                                     | Addons               | No  | 60 |
| [cf_default_allowed_methods](#cf_default_allowed_methods)                                   | Addons               | No  | ["GET", "HEAD", "POST", "OPTIONS", ["](#"PUT)PUT", "PATCH", "DELETE"]  |
| [cf_default_cached_methods](#cf_default_cached_methods)                                     | Addons               | No  | ["GET", "HEAD"] |
| [cf_min_ttl](#cf_min_ttl)                                                                   | Addons               | No  | 0 |
| [cf_max_ttl](#cf_max_ttl)                                                                   | Addons               | No  | 31536000 |
| [cf_default_ttl](#cf_default_ttl)                                                           | Addons               | No  | 86400 |
| [cf_price_class](#cf_price_class)                                                           | Addons               | No  | PriceClass_All |
| [cloudwatch_logs_enabled](#cloudwatch_logs_enabled)                                         | Addons               | No  | false |
| [cloudwatch_log_group](#cloudwatch_log_group)                                               | Addons               | No  | "datakube" |
| [cloudwatch_log_retention](#cloudwatch_log_retention)                                       | Addons               | No  | 90 |
| [cloudwatch_image_tag](#cloudwatch_image_tag)                                               | Addons               | No  | "v1.4-debian-cloudwatch" |
| [cluster_autoscaler_enabled](#cluster_autoscaler_enabled)                                   | Addons               | No  | false |
| [custom_kube2iam_roles](#custom_kube2iam_roles)                                             | Addons               | No  | [] |
| [datacube_wms_enabled](#datacube_wms_enabled)                                               | Addons               | No  | false |
| [datacube_wps_enabled](#datacube_wps_enabled)                                               | Addons               | No  | false |
| [dns_proportional_autoscaler_enabled](#dns_proportional_autoscaler_enabled)                 | Addons               | No  | false |
| [dns_proportional_autoscaler_coresPerReplica](#dns_proportional_autoscaler_coresPerReplica) | Addons               | No  | 256 |
| [dns_proportional_autoscaler_nodesPerReplica](#dns_proportional_autoscaler_nodesPerReplica) | Addons               | No  | 16 |
| [dns_proportional_autoscaler_minReplica](#dns_proportional_autoscaler_minReplica)           | Addons               | No  | 2 |
| [external_dns_enabled](#external_dns_enabled)                                               | Addons               | No  | false |
| [flux_enabled](#flux_enabled)                                                               | Addons               | No  | false |
| [flux_git_repo_url](#flux_git_repo_url)                                                     | Addons               | No  | "git@github.com:opendatacube/datacube-k8s-eks |
| [flux_git_branch](#flux_git_branch)                                                         | Addons               | No  | dev |
| [flux_git_path](#flux_git_path)                                                             | Addons               | No  | "" |
| [flux_git_label](#flux_git_label)                                                           | Addons               | No  | "flux-sync" |
| [fluxcloud_enabled](#fluxcloud_enabled)                                                     | Addons               | No  | false |
| [fluxcloud_slack_url](#fluxcloud_slack_url)                                                 | Addons               | No  | "" |
| [fluxcloud_slack_channel](#fluxcloud_slack_channel)                                         | Addons               | No  | "" |
| [fluxcloud_slack_name](#fluxcloud_slack_name)                                               | Addons               | No  | "" |
| [fluxcloud_slack_emoji](#fluxcloud_slack_emoji)                                             | Addons               | No  | "" |
| [fluxcloud_github_url](#fluxcloud_github_url)                                               | Addons               | No  | "" |
| [fluxcloud_commit_template](#fluxcloud_commit_template)                                     | Addons               | No  | "{{ .VCSLink }}/commit/{{ .Commit }}"  |
| [jhub_cognito_auth_enabled](#jhub_cognito_auth_enabled)                                     | Addons               | No  | false |
| [jhub_callback_url](#jhub_callback_url)                                                     | Addons               | No  | "https:///jhub.example.com/"
| [oauth_callback](#oauth_callback)"                                                          | Addons               | No  |  |
| [metrics_server_enabled](#metrics_server_enabled)                                           | Addons               | No  | false |
| [prometheus_enabled](#prometheus_enabled)                                                   | Addons               | No  | false |

# Infra

## region

The AWS region you wish to deploy this cluster in, this value should match your AWS_DEFAULT_REGION environment variable. This region must have support for Amazon EKS.

Example:
```
region = "us-west-2"
```

## owner

Tags most resources created by this template with an `Owner` tag.

Example:
```
owner = "Team Name"
```

## cluster_name

The name of the eks cluster that will be deployed by this template, we recommend it matches the name of the workspace. 

Example:
```
cluster_name = "dev-eks-datacube"
```

## cluster_version

EKS Cluster version to use, must be a supported version as per [EKS Docs](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html) 

N.B. This only controls the Kubernetes version of the Managed EKS Service, you will also have to ensure the nodes are running a compatible version. 

This can be changed on a running cluster to update the version of your kubernetes EKS service, you should always consult [EKS Upgrade Docs](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html) before upgrading a cluster, as there are usually application updates that must be applied first.

Example:
```
cluster_version = "1.13"
```

## eks_service_user

EKS service account IAM user to manage kubernetes cluster other than cluster admin user. This will grant service account user to interact with cluster by updating aws-auth ConfigMap within kubernetes.

See [Manage Users for you Cluster](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html) for more details and configuration options.

Example:
```
eks_service_user = "dev-eks-deployer"
```

## admin_access_CIDRs

Locks api access to these addresses, address must be in [CIDR Notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)

Example: 
```
admin_access_CIDRs = {
  "Office IP" = "1.2.3.4/32",
  "Jane Home" = "12.34.56.78/32"
}
```

## users

A list of users that will be given access to the cluster in the form `user\jdoe` these users must already exist in AWS IAM

See [Additional Users](https://github.com/opendatacube/datacube-k8s-eks/blob/master/docs/additional_users.md) for more details and configuration options.

These users will need to be in the `user.${var.cluster_name}` AWS IAM role to access the cluster. 

Example:
```
users = [
  "user/jdoe",
  "user/usmith",
]
```

## user_custom_policy

This is an optional variable. If provided will creates a custom policy and attach it to EKS user role (`user.${var.cluster_name}`) to access other services

Example:
```
user_custom_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["sqs:*"],
      "Resource": "*"
    }
  ]
}
EOF
```

## user_additional_policy_arn

This is an optional variable. If provided will add pre-defined policy to EKS user role (`user.${var.cluster_name}`) to access other services.

Example:
```
user_additional_policy_arn = [
  "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
]
```

## domain_name

The domain name to be used by for applications deployed to the cluster and using ingress.
This domain should be configured as a hosted zone in Route 53 _Before_ deploying the cluster, it should be publicaly routable. See the [AWS Doco](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html) for instructions on how to do this.

Depending on your config this domain will be used to:
    
* Point to the cloudfront distribution
* Create a wildcard certificate of `*.${var.domain_name}` for use in Application Load Balancers
* Automatically create sub-domains with external_dns

Example:
```
domain_name = "sandbox.business.com"
```

## create_certificate

If this is set to `true` a wildcard certificate of `*.${var.domain_name}` will be created and validated for you.

You _must_ have a publically available route53 hosted zone for this to work. 

Example:
```
create_certificate = true
```

## db_instance_enabled

If this is set to `true` a PostgreSQL RDS will be created in your VPC, as this is a requirement for any Open Data Cube installation, you should probably keep this enabled.

Example:
```
db_instance_enabled = true
```

## db_name

The name of your RDS database instance

Example:
```
db_name = "datacube-eks"
```

## db_multi_az

If set to true your RDS will have read replicas in other Availability Zones, recommended for production environments to ensure the system will tolerate failure of an Availability Zone. Will increase cost.

Example:
```
db_multi_az = true
```

## store_db_credentials

If true, db credentials will be stored in a kubernetes secret in the default namespace with a name that matches the value set to `cluster_name`

Example:
```
store_db_credentials = true
```

## db_storage

RDS storage size in GB, If this is increased it cannot be decreased. 

Example:
```
db_storage = 500
```

## max_db_storage

Enables storage autoscaling up to this amount, must be equal to or greater than db_storage, if this value is 0, storage autoscaling is disabled.

When max_db_storage is any value other than 0, db_storage size is ignored by terraform to ensure it doesn't try and undto the autoscaling.

Example:
```
max_db_storage = 500
```


## db_extra_sg

Enables an extra security group to access the RDS, this is potentially useful if you wish to use lambda's or extra EC2 instances to perform database admin tasks.

Example:
```
db_extra_sg = "sg-01b1c252cbf21c553"
db_extra_sg = "sg-01b203b405b608b80"
```

## vpc_cidr

The network CIDR you wish to use for this VPC, if you have organisational requirements to configure peering etc this is necessary. Otherwise the defaults are sane for most use-cases.

Example:
```
vpc_cidr = "10.0.0.0/16"
```

## public_subnet_cidrs

List of public cidrs, for all available availability zones. Example: 10.0.0.0/24 and 10.0.1.0/24

Should be large enough to cope with the load balancers required for your environment

Example:
```
public_subnet_cidrs = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
```

## private_subnet_cidrs

List of private cidrs, for all available availability zones. Example: 10.0.0.0/24 and 10.0.1.0/24

Should be fairly large as EKS will assign IP addresses to each pod

Example:
```
private_subnet_cidrs = ["10.0.32.0/19", "10.0.64.0/19", "10.0.96.0/19"]
```

## database_subnet_cidrs

List of database cidrs, for all available availability zones. Example: 10.0.0.0/24 and 10.0.1.0/24

Can be fairly small as the only thing deployed in this zone is the RDS / subnet group

Example:
```
database_subnet_cidrs = ["10.0.20.0/22", "10.0.24.0/22", "10.0.28.0/22"]
```

## enable_ec2_ssm 

Enables the IAM policy required for AWS EC2 System Manager in the EKS Node IAM role created.

This is recommended instead of SSH access as it ensures users have valid IAM credentials to access the cluster, and means you don't need to make the instances publically available or deploy an extra bastion host.

Examples:
```
enable_ec2_ssm = true
```


# Nodes

## ami_image_id

Overwrites the default ami (latest Amazon EKS)

This variable can be used to deploy a patched / customised version of the Amazon EKS image

Example:
```
ami_image_id = "ami-12345678901234567"
```

## node_group_name

Seperate Autoscaling groups by group_name for doing blue / green deployments

This name is used to tag instances and ASGs 

## default_worker_instance_type

The Worker instance type that the cluster nodes will run, for production we recommend something with a good network, as most of the Open Data Cube work is I/O bound, For example r4.4xlarge or c5n.4xlarge.

## group_enabled

If the instances in this group should be created or not, useful for swapping out instances between blue/ green

## spot_nodes_enabled

Creates a second set of Autoscaling groups (one per AZ) that are configured to run Spot instances, these instances are cheaper but can be removed any-time. Useful for fault tolerant processing work.

You can tell pods to run on Spot nodes by setting an affinity for nodetype = spot

## min_nodes

The minimum number of on-demand nodes to run

## desired_nodes

Desired number of nodes only used when first launching the cluster afterwards you should scale with something like cluster-autoscaler.

## max_nodes

Max number of nodes you want to run, useful for controlling max cost of the cluster.

## min_spot_nodes

The minimum number of spot nodes to run.

Good idea to keep this at 0, and allow cluster-autoscaler to create the nodes when you need them for processing jobs

## max_spot_nodes

Max number of spot you want to run, useful for controlling max cost of the cluster.

## min_nodes_per_az

:warning: Deprecated, use [min_nodes](#min_nodes) instead :warning:

The minimum number of on-demand nodes to run per Availability Zone, because of issues with how AWS handles autoscaling we currently deploy an ASG per availability zone

## desired_nodes_per_az

:warning: Deprecated, use [desired_nodes](#desired_nodes) instead :warning:

Desired number of nodes per AZ, only used when first launching the cluster afterwards you should scale with something like cluster-autoscaler.

## max_nodes_per_az

:warning: Deprecated, use [max_nodes](#max_nodes) instead :warning:

Max number of nodes you want to run per AZ, useful for controlling max cost of the cluster.

## min_spot_nodes_per_az

:warning: Deprecated, use [min_spot_nodes](#min_spot_nodes) instead :warning:

The minimum number of spot nodes to run per Availability Zone, because of issues with how AWS handles autoscaling we currently deploy an ASG per availability zone

Good idea to keep this at 0, and allow cluster-autoscaler to create the nodes when you need them for processing jobs

## max_spot_nodes_per_az

:warning: Deprecated, use [max_spot_nodes](#max_spot_nodes) instead :warning:

Max number of spot you want to run per AZ, useful for controlling max cost of the cluster.

## max_spot_price

the max in USD you want to pay for each spot intance per hour, This will differ depending on the instance type you've selected. 
You can see a history of market prices for each instance type in the AWS EC2 service in the web console.

## volume_size

The Disk size for your on-demand nodes. If you're getting pods evicted for ephemeral storage saving, you should increase this.

## spot_volume_size

The Disk size for your spot nodes. If you're getting pods evicted for ephemeral storage saving, you should increase this.

## extra_userdata

Additional EC2 user data commands that will be passed to EKS nodes, useful for installing extra apps on each node

# Addons

## txt_owner_id

This is used in the text record that is used to identify route53 records created by externalDns

## autoscaler-scale-down-unneeded-time

How long to leave a node that isn't needed before scaling it down, if you have very transient jobs (Dask) you may want to increase this to keep the cluster warm for longer.

## alb_ingress_enabled

Installs alb-ingress-controller, this will create an Application Load Balancer for your web-app when you create an ingress resource with the ingress type of `alb`

## cf_enable

Creates a CloudFront distribution

## cf_dns_record

A DNS record that will be created and pointed to your CloudFront distribution,

This value will be combined with `$var.domain_name` so

Example:
```
domain_name = "consoto.org"
cf_dns_record = "ows"
```

Will create a route53 record `ows.consoto.org` that points to your CloudFront Distribution

## cf_origin_dns_record

The DNS entry the CloudFront Distribution will point it's requests too. This should be on the same ALB as the webservice you wish to cache. 

For example: 
```
domain_name = "consoto.org"
cf_dns_record = "ows"
cf_origin_dns_record = "cached-alb"
```

Will need the following in the ows helm chart config
```
    ingress:
      enabled: true
      hosts:
      - ows.consoto.org
      - cached-alb.consoto.org
```

you'll need to deploy the cloudfront distribution before the ALB, or external-dns will create a record that conflicts with it.


## cf_custom_aliases

A list of custom aliases, that you wish to add to the CloudFront Distribution, if you set this you'll need to manually provision an ACM cert in us-east-1 that includes these domains. You can pass this ACM certificate to the CloudFront Distribution by setting `cf_certificate_arn`

## cf_certificate_arn

Custom certificate that includes the custom aliases

## cf_certificate_create

If you aren't using a custom cert, enable this to automatically create and validate a certificate for the CloudFront Distribution,

```
domain_name = "consoto.org"
cf_dns_record = "ows"
cf_certificate_create = true
```

will create a certificate in us-east-1 for ows.consoto.org

## cloudfront_log_bucket

S3 Bucket to store cloudfront logs

Support both the form `<bucketname>` or `<bucketname>.s3.amazonaws.com` 

If `cf_log_bucket_create` is set to `false`, this bucket must already exist in your AWS account and be configured to allow cloudfront to write logs to it.
see [Cloudfront Access Logs Guide](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html)

Example:
```
cloudfront_log_bucket = "cloudfront-logs.s3.amazonaws.com"
```

## cf_log_bucket_create

Creates a cloudfront distribution log bucket.

## cf_origin_protocol_policy

The protocol to talk to the origin (cached-alb) on, if you're using alb with https only you'll have to set this to https-only.

```
cf_origin_protocol_policy = "https-only"
```

## cf_origin_timeout

The time cloudfront will wait for a response from origin

## cf_default_allowed_methods

A list of HTTP methods that cloudfront will accept

## cf_default_cached_methods

A list of HTTP methods that cloudfront will cache

## cf_min_ttl

Min seconds to cache requests

```
cf_min_ttl = 10
```

## cf_max_ttl

Max time to cache requests

## cf_default_ttl

Default cache time

```
cf_default_ttl = 604800
```

## cf_price_class

The Price class for this distribution, can be PriceClass_100, PriceClass_200 or PriceClass_All

## cloudwatch_logs_enabled

If true will configure cloudwatch to accept logs, and fluentd agents on cluster to ship them

## cloudwatch_log_group

The name of your log group

## cloudwatch_log_retention

Number of days to keep logs

## cloudwatch_image_tag

The fluentd image to use on the cluster

## cluster_autoscaler_enabled

Enables autoscaling, the autoscaler will detect when pods are stuck in `Pending` state due to lack of resources and increase the number of nodes in the cluster up to the max.

Clutser-Autoscaler will also scale down if nodes are being underutilised.

## custom_kube2iam_roles

A list of roles that can be used by kube2iam, roles will be prefixedd with the cluster name, and can be assigned to pods via the annotation, for example this annotation will enable the pods to run this role (deployed on a cluster called dev-eks-datacube)

```
      annotations:
        iam.amazonaws.com/role: dev-eks-datacube-eks-wms
````

```
custom_kube2iam_roles = [
  {
    name = "eks-wms"
    policy = <<-EOF
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
]
```

## datacube_wms_enabled

Creates roles and infrastructure required to deploy datacube-ows

## datacube_wps_enabled

Creates roles and infrastructure required to deploy datacube-wps

## dns_proportional_autoscaler_enabled

Scales core-dns depending on the number of cores / nodes useful when running large dask clusters that overload the core-dns pod

## dns_proportional_autoscaler_coresPerReplica
## dns_proportional_autoscaler_nodesPerReplica
## dns_proportional_autoscaler_minReplica


## external_dns_enabled

Creates domain names automatically when they are specified in ingress resources and are subdomains of `$var.domain_name`

## flux_enabled

Enables Weaveworks flux, a tool used to automate deployment of helm-releases and new docker images by syncing config to a git repo. 

Recommended for production deployments.

## flux_git_repo_url

The git repo to use as a config store

## flux_git_branch

The branch to use (you can have multiple clusters managed in a single repo)

## flux_git_path

The path the use (you can have multiple clusters managed in a single repo)

## flux_git_label

The label to apply to the current running changes on the cluster

## fluxcloud_enabled

Fluxcloud will manage alerts for the changes, when configured you can send slack notifications after each deployment (recommended for prodcution environments)

## fluxcloud_slack_url

A slack webhook to send alerts to

## fluxcloud_slack_channel

The name of a the slack channel you've created the webhook on

## fluxcloud_slack_name

The name you wish to post as

## fluxcloud_slack_emoji

An emoji to use as the profile image for the user

## fluxcloud_github_url

The github url to use when building links to the commits

## fluxcloud_commit_template

Template to build links to commits

## jhub_cognito_auth_enabled

Creates a cognito user pool for use in a zero-to-jupyterhub deployment

## jhub_callback_url

callback url for cognito, will need to match your jupytherhub config

## metrics_server_enabled

Creates metrics server (not really any reason you don't want this)

## prometheus_enabled

Enables prometheus for monitoring services (will deploy a grafana server at mgmt.$var.domain_name)



 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
