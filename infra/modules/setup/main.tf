data "aws_caller_identity" "current" {
}

data "aws_eks_cluster" "odc" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "odc" {
  name = var.cluster_name
}


provider "kubernetes" {
  load_config_file       = false
  host                   = "${data.aws_eks_cluster.odc.endpoint}"
  cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.odc.certificate_authority.0.data)}"
  token                  = "${data.aws_eks_cluster_auth.odc.token}"
}
