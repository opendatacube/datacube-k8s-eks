# Fetch OIDC provider thumbprint for root CA
data "external" "thumbprint" {
  program = ["${path.module}/oidc-thumbprint.sh", local.region]
}

resource "aws_iam_openid_connect_provider" "identity_provider_example" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.external.thumbprint.result.thumbprint]
  url             = "https://oidc.eks.ap-southeast-2.amazonaws.com/id/4E493A42178CCB4A591DBB390593EA9C"
}
