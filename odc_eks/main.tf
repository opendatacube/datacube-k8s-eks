data "aws_availability_zones" "available" {
}

module "odc_eks_label" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.4.0"
  namespace  = var.namespace
  stage      = var.environment
  name      = "odc-eks"
  delimiter  = "-"
}

module "vpc" {
  # https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=v2.2.0"
  #source  = "terraform-aws-modules/vpc/aws"
  #version = "2.2.0"

  name             = "${module.odc_eks_label.id}-vpc"
  cidr             = var.vpc_cidr
  azs              = data.aws_availability_zones.available.names
  public_subnets   = var.public_subnet_cidrs
  private_subnets  = var.private_subnet_cidrs
  database_subnets = var.database_subnet_cidrs

  private_subnet_tags = {
    "SubnetType"                                       = "Private"
    "kubernetes.io/cluster/${module.odc_eks_label.id}" = "shared"
    "kubernetes.io/role/internal-elb"                  = "1"
  }

  public_subnet_tags = {
    "SubnetType"                                       = "Utility"
    "kubernetes.io/cluster/${module.odc_eks_label.id}" = "shared"
    "kubernetes.io/role/elb"                           = "1"
  }

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway           = true
  create_database_subnet_group = true
  enable_s3_endpoint           = true

  tags = {
    workspace  = terraform.workspace
    owner      = var.owner
    cluster    = module.odc_eks_label.id
    "kubernetes.io/cluster/${module.odc_eks_label.id}" = "shared"
    Created_by = "terraform"
  }
}

# Database
module "db" {
  source = "./modules/database_layer"

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
  cluster   = module.odc_eks_label.id
  workspace = terraform.workspace
}


# Creates network and Kuberenetes master nodes
module "eks" {
  source             = "./modules/eks"
  vpc_id             = module.vpc.vpc_id
  eks_subnet_ids     = module.vpc.private_subnets
  cluster_name       = module.odc_eks_label.id
  cluster_version    = var.cluster_version
  admin_access_CIDRs = var.admin_access_CIDRs

  user_custom_policy         = var.user_custom_policy
  user_additional_policy_arn = var.user_additional_policy_arn

  enable_ec2_ssm     = var.enable_ec2_ssm

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

module "jhub_cognito_auth" {
  source               = "./modules/cognito"

  cognito_auth_enabled = var.jhub_cognito_auth_enabled
  auto_verify          = var.cognito_auto_verify
  user_pool_name       = "${module.odc_eks_label.id}-jhub-userpool"
  user_pool_domain     = "${module.odc_eks_label.id}-jhub-auth"
  callback_url         = "https://${var.app_name}.${var.domain_name}/oauth_callback"
  user_groups          = var.jhub_cognito_user_groups
}
