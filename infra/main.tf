data "aws_availability_zones" "available" {
}

module "vpc" {
  # https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.2.0"

  name             = "${var.cluster_name}-vpc"
  cidr             = var.vpc_cidr
  azs              = data.aws_availability_zones.available.names
  public_subnets   = var.public_subnet_cidrs
  private_subnets  = var.private_subnet_cidrs
  database_subnets = var.database_subnet_cidrs

  private_subnet_tags = {
    "SubnetType"                                = "Private"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }

  public_subnet_tags = {
    "SubnetType"                                = "Utility"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway           = true
  create_database_subnet_group = true
  enable_s3_endpoint           = true

  tags = {
    workspace  = terraform.workspace
    owner      = var.owner
    cluster    = var.cluster_name
    Created_by = "terraform"
  }
}

# Database
# module "db" {
#   source = "./modules/database_layer"

#   # Networking
#   vpc_id                = module.vpc.vpc_id
#   database_subnet_group = module.vpc.database_subnets

#   db_name                = var.db_name
#   rds_is_multi_az        = var.db_multi_az
#   # extra_sg could be empty, so we run compact on the list to remove it if it is
#   access_security_groups = compact([module.eks.node_security_group, var.db_extra_sg])
#   storage                = var.db_storage
#   db_max_storage         = var.db_max_storage

#   # Tags
#   owner     = var.owner
#   cluster   = var.cluster_name
#   workspace = terraform.workspace
# }


# Creates network and Kuberenetes master nodes
module "eks" {
  source             = "./modules/eks"
  vpc_id             = module.vpc.vpc_id
  eks_subnet_ids     = module.vpc.private_subnets
  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  admin_access_CIDRs = var.admin_access_CIDRs

  users                      = var.users
  user_custom_policy         = var.user_custom_policy
  user_additional_policy_arn = var.user_additional_policy_arn

  enable_ec2_ssm     = var.enable_ec2_ssm

  # db_admin_username = "fred" #module.db.db_admin_username
  # db_admin_password = "fred" #module.db.db_admin_password
  # db_hostname       = "fred" #module.db.db_hostname
  # store_db_creds    = var.store_db_credentials

  # eks_service_user  = var.eks_service_user

  # Worker configuration
  owner                        = var.owner
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
  extra_userdata               = var.extra_userdata
  volume_size                  = var.volume_size
  spot_volume_size             = var.spot_volume_size

}



module "addons" {
   source = "./modules/addons"
   cluster_id                   = module.eks.cluster_id
}


# module "addons" {
#   source = "./modules/addons"

#   cluster_id                   = module.eks.cluster_id
#   cluster_api_endpoint         = module.eks.api_endpoint
#   cluster_ca                   = module.eks.cluster_ca
#   cluster_arn                  = module.eks.cluster_arn

#   owner                        = var.owner
#   domain_name = var.domain_name
  
  
#   external_dns_enabled = var.external_dns_enabled
#   txt_owner_id = var.txt_owner_id

#   cloudwatch_logs_enabled = var.cloudwatch_logs_enabled
#   cloudwatch_log_group = var.cloudwatch_log_group
#   cloudwatch_log_retention = var.cloudwatch_log_retention

#   alb_ingress_enabled = var.alb_ingress_enabled
#   prometheus_enabled = var.prometheus_enabled

#   cluster_autoscaler_enabled = var.cluster_autoscaler_enabled
#   autoscaler-scale-down-unneeded-time = var.autoscaler-scale-down-unneeded-time
#   aws_region = var.region


#   metrics_server_enabled = var.metrics_server_enabled

#   waf_environment = var.waf_environment

#   dns_proportional_autoscaler_enabled = var.dns_proportional_autoscaler_enabled
#   dns_proportional_autoscaler_coresPerReplica = var.dns_proportional_autoscaler_coresPerReplica
#   dns_proportional_autoscaler_nodesPerReplica = var.dns_proportional_autoscaler_nodesPerReplica
#   dns_proportional_autoscaler_minReplica = var.dns_proportional_autoscaler_minReplica

#   custom_kube2iam_roles = var.custom_kube2iam_roles
# }