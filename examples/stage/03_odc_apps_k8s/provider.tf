provider "aws" {
  region      = data.terraform_remote_state.odc_eks-stage.outputs.region
  max_retries = 10
  # skip region validation until terraform provider supports this new region
  skip_region_validation = true
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
