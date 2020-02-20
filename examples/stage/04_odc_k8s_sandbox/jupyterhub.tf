data "template_file" "jupyterhub" {
  template = file("${path.module}/config/jupyterhub.yaml")
  vars = {
    region          = local.region
    cluster_name    = local.cluster_id
    role_name       = module.odc_role_jupyterhub.role_name
    certificate_arn = local.certificate_arn
    sandbox_host_name = local.sandbox_host_name
    db_hostname     = local.db_hostname
    db_username     = local.db_username
    db_password     = local.db_password
    db_name         = local.db_name

    jhub_userpool_id        = module.jhub_cognito_auth.userpool_id
    jhub_userpool_domain    = module.jhub_cognito_auth.userpool_domain
    jhub_auth_client_id     = module.jhub_cognito_auth.client_id
    jhub_auth_client_secret = module.jhub_cognito_auth.client_secret
  }
}

resource "kubernetes_secret" "jupyterhub" {
  metadata {
    name = "jhub"
    namespace = kubernetes_namespace.sandbox.metadata[0].name
  }

  data = {
    "values.yaml" = data.template_file.jupyterhub.rendered
  }

  type = "Opaque"
}