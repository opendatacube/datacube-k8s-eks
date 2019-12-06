data "aws_eks_cluster_auth" "odc" {
  name = aws_eks_cluster.eks.name
}


provider "kubernetes" {
  load_config_file       = false
#  host                   = data.aws_eks_cluster.odc.endpoint
  host                   = aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.odc.token
}
