data "aws_eks_cluster" "eks" {
  name = "${true ? var.cluster_name : null_resource.aws-eks-config.id}"
}

data "aws_caller_identity" "current" {}

provider "kubernetes" {
  config_context_cluster = "${data.aws_eks_cluster.eks.arn}"
}