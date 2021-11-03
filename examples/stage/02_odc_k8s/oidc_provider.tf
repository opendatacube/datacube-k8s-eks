# Fetch OIDC provider thumbprint for root CA
data "external" "thumbprint" {
  program = ["${path.module}/oidc-thumbprint.sh", local.region]
}

resource "aws_iam_openid_connect_provider" "identity_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.external.thumbprint.result.thumbprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}
