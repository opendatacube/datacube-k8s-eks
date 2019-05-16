terraform {
  required_version = ">= 0.11.0"

  backend "s3" {
    # Force encryption
    encrypt = true
  }
}

data "aws_availability_zones" "available" {}

module "vpc" {
  # https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.64.0"

  name = "${var.cluster_name}-vpc"
  cidr = "${var.vpc_cidr}"

  azs              = "${var.availability_zones}"
  public_subnets   = "${var.public_subnet_cidrs}"
  private_subnets  = "${var.private_subnet_cidrs}"
  database_subnets = "${var.database_subnet_cidrs}"

  private_subnet_tags = {
    "SubnetType"                        = "Private"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"   = "1"
  }

  public_subnet_tags = {
    "SubnetType"                        = "Utility"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"            = "1"
  }

  # Use nat instances instead
  enable_nat_gateway           = true
  create_database_subnet_group = true
  enable_s3_endpoint           = true

  tags = {
    workspace  = "${terraform.workspace}"
    owner      = "${var.owner}"
    cluster    = "${var.cluster_name}"
    Created_by = "terraform"
  }
}

# Creates network and Kuberenetes master nodes
module "eks" {
  source             = "modules/eks"
  vpc_id             = "${module.vpc.vpc_id}"
  eks_subnet_ids     = ["${module.vpc.private_subnets}"]
  cluster_name       = "${var.cluster_name}"
  admin_access_CIDRs = "${var.admin_access_CIDRs}"
  users              = "${var.users}"
}

# Hosted zones for apps
module "mgmt_zone" {
  source       = "modules/hosted_zone"
  domain       = "${var.mgmt_domain}"
  zone         = "${var.app_zone}"
  owner        = "${var.owner}"
  cluster_name = "${var.cluster_name}"
}

module "app_zone" {
  source       = "modules/hosted_zone"
  domain       = "${var.app_domain}"
  zone         = "${var.app_zone}"
  owner        = "${var.owner}"
  cluster_name = "${var.cluster_name}"
}

# Cloudfront for caching
module "cloudfront" {
  source                  = "modules/cloudfront"
  app_domain              = "*.${var.cached_app_domain}"
  app_zone                = "${var.app_zone}"
  origin_domain           = "alb.app.${var.app_zone}"
  origin_id               = "${var.cluster_name}_${terraform.workspace}_origin"
  origin_protocol_policy  = "http-only"
  enable_distribution     = true
  enable                  = "${var.cloudfront_enabled}"
  log_bucket              = "${var.cloudfront_log_bucket}"
  log_prefix              = "${var.cluster_name}_${terraform.workspace}"
  default_allowed_methods = ["GET", "HEAD", "POST", "OPTIONS", "PUT", "PATCH", "DELETE"]
  custom_aliases          = "${var.custom_aliases}"
  create_certificate      = "${var.create_certificate}"
}

# Database
module "db" {
  source = "modules/database_layer"

  # Networking
  vpc_id                = "${module.vpc.vpc_id}"
  database_subnet_group = "${module.vpc.database_subnets}"

  dns_name               = "${var.db_dns_name}"
  zone                   = "${var.db_dns_zone}"
  db_name                = "${var.db_name}"
  rds_is_multi_az        = "${var.db_multi_az}"
  access_security_groups = ["${module.eks.node_security_group}"]

  # Tags
  owner     = "${var.owner}"
  cluster   = "${var.cluster_name}"
  workspace = "${terraform.workspace}"
}

module "green_nodes" {
  source = "modules/workers"

  # Standard variables for each worker group
  cluster_name          = "${var.cluster_name}"
  owner                 = "${var.owner}"
  eks_cluster_version   = "${module.eks.eks_cluster_version}"
  api_endpoint          = "${module.eks.api_endpoint}"
  cluster_ca            = "${module.eks.cluster_ca}"
  nodes_subnet_group    = "${module.vpc.private_subnets}"
  node_security_group   = "${module.eks.node_security_group}"
  node_instance_profile = "${module.eks.node_instance_profile}"
  min_nodes             = "${var.min_nodes}"
  max_nodes             = "${var.max_nodes}"
  min_spot_nodes        = "${var.min_spot_nodes}"
  max_spot_nodes        = "${var.max_spot_nodes}"
  max_spot_price        = "${var.max_spot_price}"
  min_dask_spot_nodes   = "${var.min_dask_spot_nodes}"
  max_dask_spot_nodes   = "${var.max_dask_spot_nodes}"
  max_dask_spot_price   = "${var.max_dask_spot_price}"

  # Different vars
  node_group_name    = "green"
  nodes_enabled      = "${var.green_nodes_enabled}"
  spot_nodes_enabled = "${local.green_spot_nodes_enabled}"
  dask_nodes_enabled = "${local.green_dask_nodes_enabled}"
  ami_image_id       = "${var.green_ami_image_id}"
}

module "blue_nodes" {
  source = "modules/workers"

  # Standard variables for each worker group
  cluster_name          = "${var.cluster_name}"
  owner                 = "${var.owner}"
  eks_cluster_version   = "${module.eks.eks_cluster_version}"
  api_endpoint          = "${module.eks.api_endpoint}"
  cluster_ca            = "${module.eks.cluster_ca}"
  nodes_subnet_group    = "${module.vpc.private_subnets}"
  node_security_group   = "${module.eks.node_security_group}"
  node_instance_profile = "${module.eks.node_instance_profile}"
  min_nodes             = "${var.min_nodes}"
  max_nodes             = "${var.max_nodes}"
  min_spot_nodes        = "${var.min_spot_nodes}"
  max_spot_nodes        = "${var.max_spot_nodes}"
  max_spot_price        = "${var.max_spot_price}"
  min_dask_spot_nodes   = "${var.min_dask_spot_nodes}"
  max_dask_spot_nodes   = "${var.max_dask_spot_nodes}"
  max_dask_spot_price   = "${var.max_dask_spot_price}"

  # Different vars
  node_group_name    = "blue"
  nodes_enabled      = "${var.blue_nodes_enabled}"
  spot_nodes_enabled = "${local.blue_spot_nodes_enabled}"
  dask_nodes_enabled = "${local.blue_dask_nodes_enabled}"
  ami_image_id       = "${var.blue_ami_image_id}"
}

module "addons" {
  source                     = "modules/addons"
  cluster_name               = "${var.cluster_name}"
  owner                      = "owner"
  alb_ingress_enabled        = "${var.addon_alb_ingress_enabled}"
  cloudwatch_logs_enabled    = "${var.addon_cloudwatch_logging_enabled}"
  cluster_autoscaler_enabled = "${var.addon_cluster_autoscaler_enabled}"
  datacube_wms_enabled       = "${var.addon_datacube_wms_enabled}"
  datacube_wps_enabled       = "${var.addon_datacube_wps_enabled}"
  external_dns_enabled       = "${var.addon_external_dns_enabled}"
}
