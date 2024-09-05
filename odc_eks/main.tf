data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_canonical_user_id" "current" {}
data "aws_cloudfront_log_delivery_canonical_user_id" "awslogsdelivery" {}

module "odc_eks_label" {
  source    = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.24.1"
  namespace = var.namespace
  stage     = var.environment
  name      = "eks"
  delimiter = "-"
}

locals {
  cluster_id = (var.cluster_id != "") ? var.cluster_id : module.odc_eks_label.id

  tags = merge(
    {
      Name        = "${local.cluster_id}-vpc"
      owner       = var.owner
      namespace   = var.namespace
      environment = var.environment
    },
    var.tags
  )

}

module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=v5.5.2"
  count = var.create_vpc ? 1 : 0

  name             = "${local.cluster_id}-vpc"
  cidr             = var.vpc_cidr
  azs              = data.aws_availability_zones.available.names
  public_subnets   = var.public_subnet_cidrs
  private_subnets  = var.private_subnet_cidrs
  database_subnets = var.database_subnet_cidrs

  secondary_cidr_blocks   = var.secondary_cidr_blocks
  map_public_ip_on_launch = var.map_public_ip_on_launch

  private_subnet_tags = {
    "SubnetType"                                = "Private"
    "kubernetes.io/cluster/${local.cluster_id}" = "shared"
    "kubernetes.io/role/internal-elb"           = var.private_subnet_elb_role == "internal-elb" ? 1 : null
    "kubernetes.io/role/elb"                    = var.private_subnet_elb_role == "elb" ? 1 : null
  }
  public_subnet_tags = {
    "SubnetType"                                = "Utility"
    "kubernetes.io/cluster/${local.cluster_id}" = "shared"
    "kubernetes.io/role/internal-elb"           = var.public_subnet_elb_role == "internal-elb" ? 1 : null
    "kubernetes.io/role/elb"                    = var.public_subnet_elb_role == "elb" ? 1 : null
  }

  database_subnet_tags = {
    "SubnetType" = "Database"
  }

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway           = var.enable_nat_gateway
  create_igw                   = var.create_igw
  create_database_subnet_group = true

  manage_default_security_group = false
  manage_default_network_acl    = false
  manage_default_route_table    = false

  enable_flow_log                   = var.create_vpc_flow_logs
  flow_log_destination_type         = "s3"
  flow_log_max_aggregation_interval = (var.create_vpc_flow_logs) ? var.flow_log_max_aggregation_interval : null
  flow_log_traffic_type             = (var.create_vpc_flow_logs) ? var.flow_log_traffic_type : null
  flow_log_file_format              = (var.create_vpc_flow_logs) ? var.flow_log_file_format : null
  flow_log_destination_arn          = (var.create_vpc_flow_logs) ? (var.create_flow_log_s3_bucket ? module.s3_bucket.arn : "arn:aws:s3:::${var.flow_log_s3_bucket_name}") : null
  
  vpc_flow_log_tags = merge(
    {
      Name        = "${local.cluster_id}-vpc-flow-logs"
      owner       = var.owner
      namespace   = var.namespace
      environment = var.environment
    },
    var.tags
  )
}

moved {
  from = module.vpc[0].aws_vpc_endpoint.s3[0]
  to   = module.vpc_endpoints[0].aws_vpc_endpoint.this["s3"]
}

module "vpc_endpoints" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git//modules/vpc-endpoints?ref=v5.1.1"
  count  = var.create_vpc && var.enable_s3_endpoint ? 1 : 0

  vpc_id             = module.vpc[0].vpc_id
  security_group_ids = [module.vpc[0].default_security_group_id]

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"

      route_table_ids = flatten([
        module.vpc[0].private_route_table_ids,
        module.vpc[0].public_route_table_ids
      ])
    }
  }

  tags = local.tags
}

# Creates network and Kuberenetes master nodes
module "eks" {
  source             = "./modules/eks"
  vpc_id             = var.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
  eks_subnet_ids     = var.create_vpc ? module.vpc[0].private_subnets : var.private_subnets
  cluster_id         = local.cluster_id
  cluster_version    = var.cluster_version
  admin_access_CIDRs = var.admin_access_CIDRs

  user_custom_policy         = var.user_custom_policy
  user_additional_policy_arn = var.user_additional_policy_arn

  enable_ec2_ssm = var.enable_ec2_ssm

  enabled_cluster_log_types       = var.enabled_cluster_log_types
  enable_custom_cluster_log_group = var.enable_custom_cluster_log_group
  log_retention_period            = var.log_retention_period

  # Worker configuration
  min_nodes                    = var.min_nodes
  max_nodes                    = var.max_nodes
  desired_nodes                = var.desired_nodes
  min_spot_nodes               = var.min_spot_nodes
  max_spot_nodes               = var.max_spot_nodes
  node_group_name              = var.node_group_name
  ami_image_id                 = var.ami_image_id
  default_worker_instance_type = var.default_worker_instance_type
  spot_nodes_enabled           = var.spot_nodes_enabled
  max_spot_price               = var.max_spot_price
  extra_kubelet_args           = var.extra_kubelet_args
  extra_bootstrap_args         = var.extra_bootstrap_args
  extra_userdata               = var.extra_userdata
  volume_encrypted             = var.volume_encrypted
  volume_size                  = var.volume_size
  volume_type                  = var.volume_type
  spot_volume_size             = var.spot_volume_size

  # Default Tags
  owner       = var.owner
  namespace   = var.namespace
  environment = var.environment

  tags            = var.tags
  node_extra_tags = var.node_extra_tags

  metadata_options = var.metadata_options
}
