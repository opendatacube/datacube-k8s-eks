data "aws_eks_cluster_auth" "odc" {
  name = var.cluster_id
}


provider "kubernetes" {
  version = "1.9"
  load_config_file       = false
  host                   = var.cluster_api_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  token                  = data.aws_eks_cluster_auth.odc.token
}
