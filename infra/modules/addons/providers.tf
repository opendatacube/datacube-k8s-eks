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

provider "helm" {
  kubernetes {
    config_context = var.cluster_arn
  }
#  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.15.1"
#  service_account = kubernetes_service_account.tiller.metadata.0.name
#  namespace       = kubernetes_service_account.tiller.metadata.0.namespace
  
  install_tiller = false
}

module "tiller" {
  source  = "iplabs/tiller/kubernetes"
  version = "3.2.1"
}
