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
# TODO aws_availability_zones used above, but var.availability_zones is used here. Any reason?
  azs              = "${data.aws_availability_zones.available.names}"
  public_subnets   = "${var.public_subnet_cidrs}"
  private_subnets  = "${var.private_subnet_cidrs}"
  database_subnets = "${var.database_subnet_cidrs}"

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

# Database
module "db" {
  source = "modules/database_layer"

  # Networking
  vpc_id                = "${module.vpc.vpc_id}"
  database_subnet_group = "${module.vpc.database_subnets}"

  hostname               = "${var.db_hostname}"
  domain_name            = "${var.db_domain_name}"
  db_name                = "${var.db_name}"
  rds_is_multi_az        = "${var.db_multi_az}"
  access_security_groups = ["${module.eks.node_security_group}"]

  # Tags
  owner     = "${var.owner}"
  cluster   = "${var.cluster_name}"
  workspace = "${terraform.workspace}"
}
