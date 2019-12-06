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

  db_admin_username = module.db.db_admin_username
  db_admin_password = module.db.db_admin_password
  db_hostname       = module.db.db_hostname
  store_db_creds    = var.store_db_credentials

  node_role_arn     = module.eks.node_role_arn
  user_role_arn     = module.eks.user_role_arn
  eks_service_user  = var.eks_service_user

}

# Database
module "db" {
  source = "./modules/database_layer"

  db_instance_enabled = var.db_instance_enabled
  # Networking
  vpc_id                = module.vpc.vpc_id
  database_subnet_group = module.vpc.database_subnets

  db_name                = var.db_name
  rds_is_multi_az        = var.db_multi_az
  # extra_sg could be empty, so we run compact on the list to remove it if it is
  access_security_groups = compact([module.eks.node_security_group, var.db_extra_sg])
  storage                = var.db_storage
  db_max_storage         = var.db_max_storage

  # Tags
  owner     = var.owner
  cluster   = var.cluster_name
  workspace = terraform.workspace
}

# module "workers" {
#   source = "./modules/workers"

#   cluster_name                 = module.eks.cluster_name
#   owner                        = var.owner
#   eks_cluster_version          = module.eks.eks_cluster_version
#   api_endpoint                 = module.eks.api_endpoint
#   cluster_ca                   = module.eks.cluster_ca
#   nodes_subnet_group           = module.vpc.private_subnets # data.aws_subnet_ids.nodes.ids
#   node_security_group          = local.node_security_group
#   node_instance_profile        = "${var.cluster_name}-node"
#   min_nodes                    = local.min_nodes
#   max_nodes                    = local.max_nodes
#   desired_nodes                = local.desired_nodes
#   min_spot_nodes               = local.min_spot_nodes
#   max_spot_nodes               = local.max_spot_nodes
#   node_group_name              = var.node_group_name
#   ami_image_id                 = var.ami_image_id
#   default_worker_instance_type = var.default_worker_instance_type
#   spot_nodes_enabled           = var.group_enabled && var.spot_nodes_enabled
#   max_spot_price               = var.max_spot_price
#   nodes_enabled                = var.group_enabled
#   extra_userdata               = var.extra_userdata
#   volume_size                 = var.volume_size
#   spot_volume_size            = var.spot_volume_size
# }
