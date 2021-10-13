data "template_file" "jupyterhub" {
  template = file("${path.module}/config/jupyterhub.yaml")
  vars = {
    region            = local.region
    cluster_name      = local.cluster_id
    certificate_arn   = local.certificate_arn
    waf_acl_id        = local.waf_acl_id
    sandbox_host_name = local.sandbox_host_name

    db_hostname = local.db_hostname
    db_username = local.sandbox_db_ro_username
    db_password = local.sandbox_db_ro_password
    db_name     = local.sandbox_db_name

    cognito_region          = local.cognito_region
    jhub_userpool_id        = local.cognito_auth_userpool_id
    jhub_userpool_domain    = local.cognito_auth_userpool_domain
    jhub_auth_client_id     = local.cognito_auth_userpool_jhub_client_id
    jhub_auth_client_secret = local.cognito_auth_userpool_jhub_client_secret

    hub_cookieSecret     = random_id.hub_cookieSecret.hex
    proxy_secretToken    = random_id.proxy_secretToken.hex
    auth_state_cryptoKey = random_id.auth_state_cryptoKey.hex
  }
}

resource "kubernetes_secret" "jupyterhub" {
  metadata {
    name      = "jupyterhub"
    namespace = kubernetes_namespace.sandbox.metadata[0].name
  }

  data = {
    "values.yaml" = data.template_file.jupyterhub.rendered
  }

  type = "Opaque"
}

resource "random_id" "hub_cookieSecret" {
  byte_length = 32
}

resource "random_id" "proxy_secretToken" {
  byte_length = 32
}

resource "random_id" "auth_state_cryptoKey" {
  byte_length = 32
}
