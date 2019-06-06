terraform {
  required_version = ">= 0.12.0"

  backend "s3" {
    # Force encryption
    encrypt = true
  }
}

# Find the resources we want to use 
# that were created as part of the eks stack
data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}

data "aws_vpcs" "vpcs" {
  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

data "aws_subnet_ids" "nodes" {
  vpc_id = element(tolist(data.aws_vpcs.vpcs.ids), 0)

  tags = {
    SubnetType = "Private"
  }
}

data "aws_security_groups" "nodes" {
  tags = {
    Name = "${var.cluster_name}-node"
  }
}

data "aws_iam_instance_profile" "node" {
  name = "${var.cluster_name}-node"
}

data "aws_autoscaling_group" "nodes" {
  count = (var.group_enabled ? 1 : 0) * length(data.aws_subnet_ids.nodes.ids)
  name  = element(module.workers.node_asg_names, count.index)
}

data "aws_autoscaling_group" "spots" {
  count = (var.group_enabled && var.spot_nodes_enabled ? 1 : 0) * length(data.aws_subnet_ids.nodes.ids)
  name  = element(module.workers.spot_node_asg_names, count.index)
}

locals {
  eks_cluster_version   = element(data.aws_eks_cluster.eks.*.version, 0)
  endpoint              = element(data.aws_eks_cluster.eks.*.endpoint, 0)
  certificate_authority = element(data.aws_eks_cluster.eks.*.certificate_authority.0.data, 0)
  node_security_group   = element(data.aws_security_groups.nodes.ids, 0)
}

module "workers" {
  source = "./modules/workers"

  cluster_name                 = var.cluster_name
  owner                        = var.owner
  eks_cluster_version          = local.eks_cluster_version
  api_endpoint                 = local.endpoint
  cluster_ca                   = local.certificate_authority
  nodes_subnet_group           = data.aws_subnet_ids.nodes.ids
  node_security_group          = local.node_security_group
  node_instance_profile        = "${var.cluster_name}-node"
  min_nodes                    = var.min_nodes_per_az
  max_nodes                    = var.max_nodes_per_az
  node_group_name              = var.node_group_name
  ami_image_id                 = var.ami_image_id
  default_worker_instance_type = var.default_worker_instance_type
  spot_nodes_enabled           = var.group_enabled && var.spot_nodes_enabled
  max_spot_price               = var.max_spot_price
  nodes_enabled                = var.group_enabled
  desired_nodes                = var.desired_nodes_per_az
  extra_userdata               = var.extra_userdata
}

