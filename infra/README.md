# AWS Datacube Terraform EKS

Terraform module which creates an EKS cluster for running Open Data Cube

EKS cluster with:
- S3 gateway
- RDS
- Cloudfront
- ACM Certificate

Optional add-ons:
- Cloudfront log export

# Requirements
- kubectl installed
- A public routable Route53 zone
- aws-iam-authenticator installed 
https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html

# Todo
- Process for patching workers
https://docs.aws.amazon.com/eks/latest/userguide/migrate-stack.html

- Process for patching masters
https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html

- Install default charts using kubernetes / helm providers as addons


# Usage

WORKSPACE=datakube-dev 

```
module "datacube" {
    source = "<insert git url>"

    # Cluster config
    region = "ap-southeast-2"
    owner = "dea"
    cluster_name = "dev-eks-datacube"

    admin_access_CIDRs = {
        "ORG" = "0.0.0.0/0"
    }

    # Data Orchestration
    bucket = "dea-public-data"
    services = ["ows"]
    topic_arn = "arn:aws:sns:ap-southeast-2:538673716275:DEANewData"

    # Cloudfront CDN
    cloudfront_enabled = true
    cached_app_domain = "*.services"
    app_zone = "dev.test.com"
    custom_aliases = []
    cloudfront_log_bucket = "dea-cloudfront-logs-dev.s3.amazonaws.com"
    create_certificate = true

    # Worker instances - General Node
    default_worker_instance_type = "m4.large"
    min_nodes = 1
    max_nodes = 6

    # Worker instances - Spot Nodes
    spot_nodes_enabled = false
    min_spot_nodes = 0
    max_spot_nodes = 6
    max_spot_price = "0.30"

    # Worker instances - Dask Nodes
    dask_nodes_enabled = false
    min_dask_spot_nodes = 0
    max_dask_spot_nodes = 6
    max_dask_spot_price = "0.30"

    # Database config
    db_dns_name = "db"
    db_dns_zone = "internal"
    db_multi_az = false

    # Addons - Kubernetes logs to cloudwatch
    cloudwatch_logging_enabled = true
    cloudwatch_log_group = "datakube"
    cloudwatch_log_retention = 90

}


```
After you build the cluster you'll need to set up your kubeconfig

```
terraform output kubeconfig >> ~/.kube/config-eks
export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config-eks
kubectl config use-context aws
```

Then create aws-auth so the nodes can join

```
terraform output config_map_aws_auth > aws-auth.yaml
kubectl apply -f aws-auth.yaml
```