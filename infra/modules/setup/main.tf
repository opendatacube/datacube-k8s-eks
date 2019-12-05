data "aws_caller_identity" "current" {
}

#data "aws_eks_cluster" "odc" {
#  name = var.cluster_name
#}

data "aws_eks_cluster_auth" "odc" {
  name = var.cluster_name
}


provider "kubernetes" {
  load_config_file       = false
#  host                   = data.aws_eks_cluster.odc.endpoint
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_endpoint)
  token                  = data.aws_eks_cluster_auth.odc.token
}
