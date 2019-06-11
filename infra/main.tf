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
  admin_access_CIDRs = var.admin_access_CIDRs
  users              = var.users
  enable_ec2_ssm     = var.enable_ec2_ssm
}

# Database
module "db" {
  source = "./modules/database_layer"

  db_instance_enabled = var.db_instance_enabled
  # Networking
  vpc_id                = module.vpc.vpc_id
  database_subnet_group = module.vpc.database_subnets

  hostname               = var.db_hostname
  domain_name            = var.db_domain_name
  db_name                = var.db_name
  rds_is_multi_az        = var.db_multi_az
  access_security_groups = [module.eks.node_security_group]

  # Tags
  owner     = var.owner
  cluster   = var.cluster_name
  workspace = terraform.workspace
}

module "setup" {
  source = "./modules/setup"

  cluster_name   = module.eks.cluster_name
  region         = var.region
  db_username    = module.db.db_username
  db_password    = module.db.db_password
  store_db_creds = var.store_db_credentials
  node_role_arn  = module.eks.node_role_arn
  user_role_arn  = module.eks.user_role_arn
}

