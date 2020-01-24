data "template_file" "jhub" {
  template = file("${path.module}/config/jhub.yaml")
  vars = {
    region       = local.region
    cluster_name = local.cluster_id
    role_name    = module.odc_role_jhub.role_name
    certificate_arn = local.certificate_arn
    node_type   = local.node_type  # use for node affinity
    domain_name = local.domain_name
    db_hostname = local.db_hostname
    db_username = local.db_username
    db_password = local.db_password
    db_name     = local.db_name
    jhub_userpool_id        = local.jhub_userpool_id
    jhub_userpool_domain    = local.jhub_userpool_domain
    jhub_auth_client_id     = local.jhub_auth_client_id
    jhub_auth_client_secret = local.jhub_auth_client_secret
  }
}

resource "kubernetes_secret" "jhub" {
  depends_on = [
    kubernetes_namespace.sandbox
  ]

  metadata {
    name = "jhub"
    namespace = "sandbox"
  }

  data = {
    "values.yaml" = data.template_file.jhub.rendered
  }

  type = "Opaque"
}