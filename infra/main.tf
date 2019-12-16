terraform {
  required_version = ">= 0.12.0"

  backend "s3" {
    # Force encryption
    encrypt = true
  }
}

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

  #Engine version
  engine_version         = var.db_engine_version

  # Tags
  owner     = var.owner
  cluster   = var.cluster_name
  workspace = terraform.workspace
}

module "setup" {
  source = "./modules/setup"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.api_endpoint
  cluster_ca        = module.eks.cluster_ca
  region            = var.region
  db_admin_username = module.db.db_admin_username
  db_admin_password = module.db.db_admin_password
  store_db_creds    = var.store_db_credentials
  node_role_arn     = module.eks.node_role_arn
  user_role_arn     = module.eks.user_role_arn
  eks_service_user  = var.eks_service_user
  db_hostname       = module.db.db_hostname
}

