module "odc_eks" {
    source = "github.com/opendatacube/datacube-k8s-eks//odc_eks?ref=terraform-aws-odc"
    #source = "../../../datacube-k8s-eks/odc_eks"
# Cluster config
region = "ap-southeast-2"

owner = "AnOwner"
cluster_name = "datacube-stage"
cluster_version = 1.13

admin_access_CIDRs = {
  "Everywhere" = "0.0.0.0/0"
}

users = [
  "role/YouAreGonnaWantThis",
]

domain_name = "stage.datacube.domain"

# System node instances
#default_worker_instance_type = "m4.large"
default_worker_instance_type = "t3.medium"
spot_nodes_enabled = true
min_nodes = 2
max_nodes = 5

# K8s addons - TODO: Will be deprecated in favour of a separate k8s CD environment
external_dns_enabled = false
txt_owner_id = "OpenDataCube"

cloudwatch_logs_enabled = false
cloudwatch_log_group = "datacube-stage"
cloudwatch_log_retention = 90

alb_ingress_enabled = false
prometheus_enabled = false

cluster_autoscaler_enabled = false
autoscaler-scale-down-unneeded-time = "5m"

metrics_server_enabled =false

waf_environment = "dev"

dns_proportional_autoscaler_enabled = false
dns_proportional_autoscaler_coresPerReplica = 32
dns_proportional_autoscaler_nodesPerReplica = 4
dns_proportional_autoscaler_minReplica = 2

# A role for WMS
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
                "arn:aws:s3:::datacube-data*"
              ]
            },
            {
              "Effect": "Allow",
              "Action": ["S3:GetObject"],
              "Resource": [
                "arn:aws:s3:::datacube-data*"
              ]
            }
          ]
        }
      EOF
    }
  ]
}
