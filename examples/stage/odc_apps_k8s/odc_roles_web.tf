# Roles for k8s web applications
# Separate TF files can be used per application but in some cases it
# is more manageable to simply group them up (e.g. Use the odc_roles and a list of roles)

module "odc_web_roles" {
//  source = "github.com/opendatacube/datacube-k8s-eks//odc_roles?ref=terraform-aws-odc"
  source = "../../../odc_roles"

  owner = local.owner
  namespace = local.namespace
  environment = local.environment

  cluster_name = local.cluster_name

  roles = [
    {
      name = "${local.cluster_name}-wms"
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
          },
          {
            "Effect": "Allow",
            "Action": ["s3:*"],
            "Resource": [
              "arn:aws:s3:::datacube-index-dump/*"
            ]
          }
        ]
      }
      EOF
    },
    {
      name  = "${local.cluster_name}-wps"
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
          },
          {
            "Effect": "Allow",
            "Action": [
              "s3:PutObject",
              "s3:GetObjectAcl",
              "s3:GetObject",
              "s3:ListBucket",
              "s3:PutObjectAcl"
            ],
            "Resource": [
              "arn:aws:s3:::dea-wps-results",
              "arn:aws:s3:::dea-wps-results/*"
            ]
          }
        ]
      }
      EOF
    }
  ]
}