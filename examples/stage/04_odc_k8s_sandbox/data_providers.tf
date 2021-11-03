data "terraform_remote_state" "odc_eks-stage" {
  backend = "s3"
  config = {
    bucket = "odc-test-stage-backend-tfstate"
    key    = "odc_eks_terraform.tfstate"
    region = "ap-southeast-2"
  }
}

data "terraform_remote_state" "odc_k8s-stage" {
  backend = "s3"
  config = {
    bucket = "odc-test-stage-backend-tfstate"
    key    = "odc_k8s_terraform.tfstate"
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

data "aws_subnet" "node_subnets" {
  count = length(data.aws_subnet_ids.nodes.ids)
  id    = tolist(data.aws_subnet_ids.nodes.ids)[count.index]
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id
}

data "aws_ssm_parameter" "sandbox_db_ro_creds" {
  count = local.db_enabled ? 1 : 0
  name  = "/${local.cluster_id}/sandbox_reader/db.creds"
}

locals {
  region      = data.terraform_remote_state.odc_eks-stage.outputs.region
  owner       = data.terraform_remote_state.odc_eks-stage.outputs.owner
  namespace   = data.terraform_remote_state.odc_eks-stage.outputs.namespace
  environment = data.terraform_remote_state.odc_eks-stage.outputs.environment

  domain_name       = data.terraform_remote_state.odc_eks-stage.outputs.domain_name
  sandbox_host_name = "sandbox.${local.domain_name}"
  certificate_arn   = data.terraform_remote_state.odc_eks-stage.outputs.certificate_arn
  waf_acl_id        = lookup(data.terraform_remote_state.odc_eks-stage.outputs, "waf_acl_id", "")

  cluster_id            = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id
  cluster_version       = data.aws_eks_cluster.cluster.version
  endpoint              = data.aws_eks_cluster.cluster.endpoint
  certificate_authority = data.aws_eks_cluster.cluster.certificate_authority[0].data

  #EKS service account variables
  oidc_arn = data.terraform_remote_state.odc_k8s-stage.outputs.oidc_arn
  oidc_url = data.terraform_remote_state.odc_k8s-stage.outputs.oidc_url

  cognito_region                           = data.terraform_remote_state.odc_eks-stage.outputs.cognito_region
  cognito_auth_userpool_id                 = data.terraform_remote_state.odc_eks-stage.outputs.cognito_auth_userpool_id
  cognito_auth_userpool_domain             = data.terraform_remote_state.odc_eks-stage.outputs.cognito_auth_userpool_domain
  cognito_auth_userpool_jhub_client_id     = data.terraform_remote_state.odc_eks-stage.outputs.cognito_auth_userpool_jhub_client_id
  cognito_auth_userpool_jhub_client_secret = data.terraform_remote_state.odc_eks-stage.outputs.cognito_auth_userpool_jhub_client_secret

  db_hostname = data.terraform_remote_state.odc_eks-stage.outputs.db_hostname
  db_enabled  = data.terraform_remote_state.odc_eks-stage.outputs.db_enabled

  sandbox_db_name        = data.terraform_remote_state.odc_eks-stage.outputs.db_name
  sandbox_db_ro_username = local.db_enabled ? element(split(":", data.aws_ssm_parameter.sandbox_db_ro_creds[0].value), 0) : ""
  sandbox_db_ro_password = local.db_enabled ? element(split(":", data.aws_ssm_parameter.sandbox_db_ro_creds[0].value), 1) : ""

  node_group_name     = "sandbox"
  node_subnets        = data.aws_subnet.node_subnets
  node_asg_zones      = ["ap-southeast-1a"] # creates ASG for specified zones
  node_security_group = data.terraform_remote_state.odc_eks-stage.outputs.node_security_group

  ami_image_id = data.terraform_remote_state.odc_eks-stage.outputs.ami_image_id

  # each creates core nodegroup(asg) with provided configurations
  core_nodes = [
    {
      instance_type   = "r5.large",
      node_size       = "L",
      min_nodes       = 1,
      desired_nodes   = 1,
      max_nodes       = 2,
      ebs_volume_size = 20,
    }
  ]

  # each creates user nodegroup(asg) with provided configurations
  user_nodes = [
    {
      instance_type   = "r5.large",
      node_size       = "L",
      min_nodes       = 0,
      desired_nodes   = 0,
      max_nodes       = 2,
      ebs_volume_size = 20,
    },
    {
      instance_type   = "r5.xlarge",
      node_size       = "XL",
      min_nodes       = 0,
      desired_nodes   = 0,
      max_nodes       = 2,
      ebs_volume_size = 20,
    },
  ]

  # each creates spot nodegroup(asg) with provided configurations
  spot_nodes = [
    {
      instance_type   = "r5.4xlarge",
      node_size       = "4XL",
      min_nodes       = 0,
      desired_nodes   = 0,
      max_nodes       = 2,
      ebs_volume_size = 20,
      max_price       = "0.40"
    }
  ]
}
