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

data "aws_vpcs" "vpcs" {
  tags = {
    Name = "${data.terraform_remote_state.odc_eks-stage.outputs.cluster_id}-vpc"
  }
}

data "aws_subnet_ids" "nodes" {
  vpc_id = element(tolist(data.aws_vpcs.vpcs.ids), 0)

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

locals {
  region        = data.terraform_remote_state.odc_eks-stage.outputs.region
  owner         = data.terraform_remote_state.odc_eks-stage.outputs.owner
  namespace     = data.terraform_remote_state.odc_eks-stage.outputs.namespace
  environment   = data.terraform_remote_state.odc_eks-stage.outputs.environment

  domain_name     = data.terraform_remote_state.odc_eks-stage.outputs.domain_name
  certificate_arn = data.terraform_remote_state.odc_eks-stage.outputs.certificate_arn

  jhub_userpool           = data.terraform_remote_state.odc_eks-stage.outputs.jhub_userpool
  jhub_userpool_id        = data.terraform_remote_state.odc_eks-stage.outputs.jhub_userpool_id
  jhub_userpool_doamin    = data.terraform_remote_state.odc_eks-stage.outputs.jhub_userpool_domain
  jhub_auth_client_id     = data.terraform_remote_state.odc_eks-stage.outputs.jhub_auth_client_id
  jhub_auth_client_secret = data.terraform_remote_state.odc_eks-stage.outputs.jhub_auth_client_secret

  db_hostname     = data.terraform_remote_state.odc_eks-stage.outputs.db_hostname
  db_username     = data.terraform_remote_state.odc_eks-stage.outputs.db_admin_username
  db_password     = data.terraform_remote_state.odc_eks-stage.outputs.db_admin_username
  db_name         = data.terraform_remote_state.odc_eks-stage.outputs.db_name

  node_group_name     = "${local.cluster_name}-jhub"
  nodes_subnet_group  = data.aws_subnet_ids.nodes.ids
  node_security_group = data.terraform_remote_state.odc_eks-stage.outputs.node_security_group

  nodes_enabled       = true
  spot_nodes_enabled  = true

  cluster_name          = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id
  eks_cluster_version   = data.aws_eks_cluster.cluster.version
  endpoint              = data.aws_eks_cluster.cluster.endpoint
  certificate_authority = data.aws_eks_cluster.cluster.certificate_authority[0].data

  ami_image_id          = data.terraform_remote_state.odc_eks-stage.outputs.ami_image_id
  default_worker_instance_type = "r5.4xlarge"
  node_type          = "ondemand"
  spot_node_type     = "spot"
  volume_size = 100
  spot_volume_size = 100
  extra_userdata        = <<-USERDATA
    echo ""
  USERDATA

  min_spot_nodes = {
    ap-southeast-2a = 0
    ap-southeast-2b = 0
    ap-southeast-2c = 0
  }
  max_spot_nodes = {
    ap-southeast-2a = 2
    ap-southeast-2b = 2
    ap-southeast-2c = 2
  }
  min_nodes = {
    ap-southeast-2a = 0
    ap-southeast-2b = 0
    ap-southeast-2c = 1
  }
  desired_nodes = {
    ap-southeast-2a = 0
    ap-southeast-2b = 0
    ap-southeast-2c = 1
  }
  max_nodes = {
    ap-southeast-2a = 2
    ap-southeast-2b = 2
    ap-southeast-2c = 2
  }
}