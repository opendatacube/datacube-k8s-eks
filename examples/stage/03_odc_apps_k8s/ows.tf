data "template_file" "ows" {
  template = file("${path.module}/config/ows.yaml")
  vars = {
    role_name   = module.odc_role_wms.role_name
    domain_name = local.domain_name

    db_name     = local.ows_db_name
    db_hostname = local.db_hostname
    db_secret   = kubernetes_secret.ows_db.metadata[0].name

    aws_creds_secret = kubernetes_secret.ows_user_creds.metadata[0].name
  }
}

resource "kubernetes_secret" "ows" {
  metadata {
    name      = "ows"
    namespace = kubernetes_namespace.web.metadata[0].name
  }

  data = {
    "values.yaml" = data.template_file.ows.rendered
  }

  type = "Opaque"
}

# OWS App Service User
module "odc_user_ows" {
  # source = "github.com/opendatacube/datacube-k8s-eks//odc_user?ref=master"
  source = "../../../odc_user"

  # Default Tags
  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment

  user = {
    name   = "svc-${local.cluster_id}-ows-user"
    policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
              "S3:ListBucket",
              "s3:ListObjects",
              "S3:GetObject"
          ],
          "Resource": [
            "arn:aws:s3:::dea-public-data",
            "arn:aws:s3:::dea-public-data/*"
          ]
        }
      ]
    }
    EOF
  }
}

resource "kubernetes_secret" "ows_user_creds" {
  metadata {
    name      = "ows-user-creds"
    namespace = kubernetes_namespace.web.metadata[0].name
  }

  data = {
    AWS_ACCESS_KEY_ID     = module.odc_user_ows.id
    AWS_SECRET_ACCESS_KEY = module.odc_user_ows.secret
    AWS_DEFAULT_REGION    = local.region
  }

  type = "Opaque"
}
