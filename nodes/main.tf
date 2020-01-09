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
  count = var.group_enabled ? length(data.aws_subnet_ids.nodes.ids) : 0
  name  = element(module.workers.node_asg_names, count.index)
}

data "aws_autoscaling_group" "spots" {
  count = var.group_enabled && var.spot_nodes_enabled ? length(data.aws_subnet_ids.nodes.ids) : 0
  name  = element(module.workers.spot_node_asg_names, count.index)
}

locals {
  eks_cluster_version   = element(data.aws_eks_cluster.eks.*.version, 0)
  endpoint              = element(data.aws_eks_cluster.eks.*.endpoint, 0)
  certificate_authority = element(data.aws_eks_cluster.eks.*.certificate_authority.0.data, 0)
  node_security_group   = element(data.aws_security_groups.nodes.ids, 0)
  # use node var or generate it from subnet count * nodes_per_az for legacy support
  # The default values are set to 0 for both the _nodes and _nodes_per_az
  min_nodes = (var.min_nodes_per_az > 0) ? { ap-southeast-2a: var.min_nodes_per_az, ap-southeast-2b: var.min_nodes_per_az, ap-southeast-2c: var.min_nodes_per_az } : var.min_nodes
  max_nodes = (var.max_nodes_per_az > 0) ? { ap-southeast-2a: var.max_nodes_per_az, ap-southeast-2b: var.max_nodes_per_az, ap-southeast-2c: var.max_nodes_per_az } : var.max_nodes
  desired_nodes = (var.desired_nodes_per_az > 0) ? { ap-southeast-2a: var.desired_nodes_per_az, ap-southeast-2b: var.desired_nodes_per_az, ap-southeast-2c: var.desired_nodes_per_az } : var.desired_nodes
  min_spot_nodes = (var.min_spot_nodes_per_az > 0) ? { ap-southeast-2a: var.min_spot_nodes_per_az, ap-southeast-2b: var.min_spot_nodes_per_az, ap-southeast-2c: var.min_spot_nodes_per_az } : var.min_spot_nodes
  max_spot_nodes = (var.max_spot_nodes_per_az > 0) ? { ap-southeast-2a: var.max_spot_nodes_per_az, ap-southeast-2b: var.max_spot_nodes_per_az, ap-southeast-2c: var.max_spot_nodes_per_az } : var.max_spot_nodes
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
  min_nodes                    = local.min_nodes
  max_nodes                    = local.max_nodes
  desired_nodes                = local.desired_nodes
  min_spot_nodes               = local.min_spot_nodes
  max_spot_nodes               = local.max_spot_nodes
  node_group_name              = var.node_group_name
  ami_image_id                 = var.ami_image_id
  default_worker_instance_type = var.default_worker_instance_type
  spot_nodes_enabled           = var.group_enabled && var.spot_nodes_enabled
  max_spot_price               = var.max_spot_price
  nodes_enabled                = var.group_enabled
  extra_userdata               = var.extra_userdata
  volume_size                 = var.volume_size
  spot_volume_size            = var.spot_volume_size
}

