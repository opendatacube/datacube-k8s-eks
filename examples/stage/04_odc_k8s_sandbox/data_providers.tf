data "terraform_remote_state" "odc_eks-stage" {
  backend = "s3"
  config = {
    bucket = "odc-test-stage-backend-tfstate"
    key    = "odc_eks_terraform.tfstate"
    region = "ap-southeast-2"
  }
}

data "aws_caller_identity" "current" {
}

data "aws_vpc" "vpc" {
  tags = {
    Name = "${data.terraform_remote_state.odc_eks-stage.outputs.cluster_id}-vpc"
  }
}

data "aws_subnet_ids" "nodes" {
  vpc_id = data.aws_vpc.vpc.id

  tags = {
    SubnetType = "Private"
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id
}

# NOTE: read SANDBOX db reader creds from parameter store
#   check examples/scripts/init_sandbox_db.sh script for reference
data "aws_ssm_parameter" "sandbox_db_ro_creds" {
  name = "/${local.cluster_id}/sandbox_ro/db.creds"
}

locals {
  region      = data.terraform_remote_state.odc_eks-stage.outputs.region
  owner       = data.terraform_remote_state.odc_eks-stage.outputs.owner
  namespace   = data.terraform_remote_state.odc_eks-stage.outputs.namespace
  environment = data.terraform_remote_state.odc_eks-stage.outputs.environment

  domain_name       = data.terraform_remote_state.odc_eks-stage.outputs.domain_name
  sandbox_host_name = "app.${local.domain_name}"
  certificate_arn   = data.terraform_remote_state.odc_eks-stage.outputs.certificate_arn
  # waf_acl_id        = tolist(data.terraform_remote_state.odc_eks-stage.outputs.waf_acl_id)[0]

  cognito_auth_userpool_id                 = data.terraform_remote_state.odc_eks-stage.outputs.cognito_auth_userpool_id
  cognito_auth_userpool_domain             = data.terraform_remote_state.odc_eks-stage.outputs.cognito_auth_userpool_domain
  cognito_auth_userpool_jhub_client_id     = data.terraform_remote_state.odc_eks-stage.outputs.cognito_auth_userpool_jhub_client_id
  cognito_auth_userpool_jhub_client_secret = data.terraform_remote_state.odc_eks-stage.outputs.cognito_auth_userpool_jhub_client_secret

  db_hostname = data.terraform_remote_state.odc_eks-stage.outputs.db_hostname

  sandbox_db_name        = "ows"
  sandbox_db_ro_username = element(split(":", data.aws_ssm_parameter.sandbox_db_ro_creds.value), 0)
  sandbox_db_ro_password = element(split(":", data.aws_ssm_parameter.sandbox_db_ro_creds.value), 1)

  node_group_name     = "sandbox"
  nodes_subnet_group  = data.aws_subnet_ids.nodes.ids
  node_security_group = data.terraform_remote_state.odc_eks-stage.outputs.node_security_group

  ami_image_id            = data.terraform_remote_state.odc_eks-stage.outputs.ami_image_id
  user_node_instance_type = "m4.large"
  user_node_volume_size   = 100
  spot_node_instance_type = "m4.large"
  spot_node_volume_size   = 100
  spot_max_price          = "0.40"

  cluster_id            = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id
  eks_cluster_version   = data.aws_eks_cluster.cluster.version
  endpoint              = data.aws_eks_cluster.cluster.endpoint
  certificate_authority = data.aws_eks_cluster.cluster.certificate_authority[0].data

  min_nodes = {
    ap-southeast-2a = 0
    ap-southeast-2b = 0
    ap-southeast-2c = 0
  }
  desired_nodes = {
    ap-southeast-2a = 0
    ap-southeast-2b = 0
    ap-southeast-2c = 0
  }
  max_nodes = {
    ap-southeast-2a = 2
    ap-southeast-2b = 2
    ap-southeast-2c = 2
  }

  spot_min_nodes = {
    us-west-2a = 0
    us-west-2b = 0
    us-west-2c = 0
  }
  spot_desired_nodes = {
    us-west-2a = 0
    us-west-2b = 0
    us-west-2c = 0
  }
  spot_max_nodes = {
    us-west-2a = 2
    us-west-2b = 2
    us-west-2c = 2
  }
}