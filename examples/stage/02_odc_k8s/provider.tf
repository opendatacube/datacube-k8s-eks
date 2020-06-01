provider "aws" {
  region      = data.terraform_remote_state.odc_eks-stage.outputs.region
  max_retries = 10
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.10"
}

provider "helm" {
  kubernetes {
    host             = data.aws_eks_cluster.cluster.endpoint
    load_config_file = false

    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}