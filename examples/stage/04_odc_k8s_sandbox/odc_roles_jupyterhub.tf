# Roles for Jupyterhub web applications
module "odc_role_jupyterhub" {
  # source = "github.com/opendatacube/datacube-k8s-eks//odc_role?ref=master"
  source = "../../../odc_role"

  # Default Tags
  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment

  cluster_id = local.cluster_id

  role = {
    name   = "${local.cluster_id}-jhub"
    policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": ["S3:ListBucket"],
          "Resource": [
            "arn:aws:s3:::dea-public-data"
          ]
        },
        {
          "Effect": "Allow",
          "Action": ["S3:GetObject"],
          "Resource": [
            "arn:aws:s3:::dea-public-data/*"
          ]
        }
      ]
    }
    EOF
  }
}