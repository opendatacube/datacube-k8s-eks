module "green_nodes" {
  source = "modules/workers"

  # Standard variables for each worker group
  cluster_name          = "${var.cluster_name}"
  owner                 = "${var.owner}"
  eks_cluster_version   = "${module.eks.eks_cluster_version}"
  api_endpoint          = "${module.eks.api_endpoint}"
  cluster_ca            = "${module.eks.cluster_ca}"
  nodes_subnet_group    = "${module.eks.nodes_subnet_group}"
  node_security_group   = "${module.eks.node_security_group}"
  node_instance_profile = "${module.eks.node_instance_profile}"
  min_nodes             = "${var.min_nodes_per_az}"
  max_nodes             = "${var.max_nodes_per_az}"
  min_spot_nodes        = "${var.min_spot_nodes_per_az}"
  max_spot_nodes        = "${var.max_spot_nodes_per_az}"
  max_spot_price        = "${var.max_spot_price}"
  min_dask_spot_nodes   = "${var.min_dask_spot_nodes_per_az}"
  max_dask_spot_nodes   = "${var.max_dask_spot_nodes_per_az}"
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
  nodes_subnet_group    = "${module.eks.nodes_subnet_group}"
  node_security_group   = "${module.eks.node_security_group}"
  node_instance_profile = "${module.eks.node_instance_profile}"
  min_nodes             = "${var.min_nodes_per_az}"
  max_nodes             = "${var.max_nodes_per_az}"
  min_spot_nodes        = "${var.min_spot_nodes_per_az}"
  max_spot_nodes        = "${var.max_spot_nodes_per_az}"
  max_spot_price        = "${var.max_spot_price}"
  min_dask_spot_nodes   = "${var.min_dask_spot_nodes_per_az}"
  max_dask_spot_nodes   = "${var.max_dask_spot_nodes_per_az}"
  max_dask_spot_price   = "${var.max_dask_spot_price}"

  # Different vars
  node_group_name    = "blue"
  nodes_enabled      = "${var.blue_nodes_enabled}"
  spot_nodes_enabled = "${local.blue_spot_nodes_enabled}"
  dask_nodes_enabled = "${local.blue_dask_nodes_enabled}"
  ami_image_id       = "${var.blue_ami_image_id}"
}
