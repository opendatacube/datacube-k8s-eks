data "terraform_remote_state" "odc_eks-stage" {
  backend = "s3"
  config = {
    bucket = "odc-test-devtest-backend-tfstate"
    key    = "odc_eks_terraform.tfstate"
    region = "ap-southeast-2"
    # skip region validation until terraform provider supports this new region
    skip_region_validation = true
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
  name = "/${local.cluster_id}/ows_ro/db.creds"
}

locals {
  region      = data.terraform_remote_state.odc_eks-stage.outputs.region
  owner       = data.terraform_remote_state.odc_eks-stage.outputs.owner
  namespace   = data.terraform_remote_state.odc_eks-stage.outputs.namespace
  environment = data.terraform_remote_state.odc_eks-stage.outputs.environment

  domain_name       = data.terraform_remote_state.odc_eks-stage.outputs.domain_name
  sandbox_host_name = "app.${local.domain_name}"
  certificate_arn   = data.terraform_remote_state.odc_eks-stage.outputs.certificate_arn
  # waf_acl_id        = data.terraform_remote_state.odc_eks-stage.outputs.waf_acl_id

  # To capture ALB access logs
  alb_log_bucket = "${local.namespace}-${local.environment}-eks-alb-logs"

  cognito_region                           = "ap-southeast-2"
  cognito_auth_userpool_id                 = data.terraform_remote_state.odc_eks-stage.outputs.cognito_auth_userpool_id
  cognito_auth_userpool_domain             = data.terraform_remote_state.odc_eks-stage.outputs.cognito_auth_userpool_domain
  cognito_auth_userpool_jhub_client_id     = data.terraform_remote_state.odc_eks-stage.outputs.cognito_auth_userpool_jhub_client_id
  cognito_auth_userpool_jhub_client_secret = data.terraform_remote_state.odc_eks-stage.outputs.cognito_auth_userpool_jhub_client_secret

  db_hostname = data.terraform_remote_state.odc_eks-stage.outputs.db_hostname
  db_enabled = data.terraform_remote_state.odc_eks-stage.outputs.db_enabled

  sandbox_db_name        = "ows"
  sandbox_db_ro_username = local.db_enabled ? element(split(":", data.aws_ssm_parameter.sandbox_db_ro_creds.value), 0) : ""
  sandbox_db_ro_password = local.db_enabled ? element(split(":", data.aws_ssm_parameter.sandbox_db_ro_creds.value), 1) : ""

  node_group_name     = "sandbox"
  node_subnets        = data.aws_subnet.node_subnets
  node_asg_zones      = ["ap-southeast-2"] # creates ASG for specified zones
  node_security_group = data.terraform_remote_state.odc_eks-stage.outputs.node_security_group

  ami_image_id = data.terraform_remote_state.odc_eks-stage.outputs.ami_image_id

  # each creates core nodegroup(asg) with provided configurations
  core_nodes = [
    {
      instance_type   = "m5.large",
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
    {
      instance_type   = "r5.2xlarge",
      node_size       = "2XL",
      min_nodes       = 0,
      desired_nodes   = 0,
      max_nodes       = 2,
      ebs_volume_size = 20,
    },
    {
      instance_type   = "r5.4xlarge",
      node_size       = "4XL",
      min_nodes       = 0,
      desired_nodes   = 0,
      max_nodes       = 2,
      ebs_volume_size = 20,
    },
    {
      instance_type   = "r5.8xlarge",
      node_size       = "8XL",
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

  # dask spot nodegroup configuration - scheduler and worker
  dask_cluster_asg_zone        = local.node_asg_zones[0]
  dask_core_node_purpose       = "dask-core"      # used for taint-tolerations configuration
  dask_scheduler_node_purpose  = "dask-scheduler" # used for taint-tolerations configuration
  dask_worker_node_purpose     = "dask-worker"    # used for taint-tolerations configuration
  dask_worker_default_profile  = "r5_L"           # choose from one of the worker prefered node_size
  dask_per_cluster_max_cores   = 40               # Maximum number of cores per cluster
  dask_per_cluster_max_workers = 5                # Maximum number of workers per cluster
  # NOTE: Currently only support one nodegroup for dask-core
  dask_core_node = {
    instance_types       = ["r5.large"],
    node_size            = "r5_L",
    min_nodes            = 1,
    desired_nodes        = 1,
    max_nodes            = 2,
    ebs_volume_size      = 20,
    on_demand_percentage = 100
  }
  # NOTE: Currently only support one nodegroup for dask-scheduler
  dask_scheduler_node = {
    instance_types       = ["r5.large", "r5d.large"],
    node_size            = "r5_L",
    min_nodes            = 0,
    desired_nodes        = 0,
    max_nodes            = 2,
    ebs_volume_size      = 20,
    on_demand_percentage = 100,
    max_cores            = 2,
    max_memory           = 16
  }
  dask_worker_nodes = [
    {
      instance_types       = ["r5.large", "r5d.large"],
      node_size            = "r5_L",
      min_nodes            = 0,
      desired_nodes        = 0,
      max_nodes            = 2,
      ebs_volume_size      = 20,
      max_price            = "0.075",
      on_demand_percentage = 0,
      max_cores            = 2,
      max_memory           = 16
    },
    {
      instance_types       = ["r5.xlarge", "r5d.xlarge"],
      node_size            = "r5_XL",
      min_nodes            = 0,
      desired_nodes        = 0,
      max_nodes            = 2,
      ebs_volume_size      = 20,
      max_price            = "0.15",
      on_demand_percentage = 0,
      max_cores            = 4,
      max_memory           = 32
    },
    {
      instance_types       = ["r5.2xlarge", "r5d.2xlarge"],
      node_size            = "r5_2XL",
      min_nodes            = 0,
      desired_nodes        = 0,
      max_nodes            = 2,
      ebs_volume_size      = 20,
      max_price            = "0.20",
      on_demand_percentage = 0,
      max_cores            = 8,
      max_memory           = 64
    },
    {
      instance_types       = ["r5.4xlarge", "r5d.4xlarge"],
      node_size            = "r5_4XL",
      min_nodes            = 0,
      desired_nodes        = 0,
      max_nodes            = 2,
      ebs_volume_size      = 20,
      max_price            = "0.40",
      on_demand_percentage = 0,
      max_cores            = 16,
      max_memory           = 128
    }
  ]

  cluster_id            = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id
  cluster_version       = data.aws_eks_cluster.cluster.version
  endpoint              = data.aws_eks_cluster.cluster.endpoint
  certificate_authority = data.aws_eks_cluster.cluster.certificate_authority[0].data
}

resource "random_id" "jhub_dask_api_token" {
  byte_length = 32
}
