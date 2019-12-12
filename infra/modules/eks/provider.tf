# data "aws_eks_cluster_auth" "odc" {
#   name = aws_eks_cluster.eks.id

#   depends_on =[
#     aws_eks_cluster.eks,
#   ]
# }


# provider "kubernetes" {
#   version = "1.9"
#   load_config_file       = false
#   host                   = aws_eks_cluster.eks.endpoint
#   cluster_ca_certificate = base64decode(aws_eks_cluster.eks.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.odc.token
# }
