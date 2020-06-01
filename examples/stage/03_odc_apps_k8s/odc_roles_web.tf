# Roles for k8s web applications
# Separate TF files can be used per application but in some cases it
# is more manageable to simply group them up (e.g. Use the odc_roles and a list of roles)

module "odc_role_ows" {
  //  source = "github.com/opendatacube/datacube-k8s-eks//odc_role?ref=master"
  source = "../../../odc_role"

  # Default Tags
  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment

  cluster_id = local.cluster_id

  role = {
    name   = "${local.cluster_id}-ows"
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