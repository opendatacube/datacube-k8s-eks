# grafana-cloudwatch service account role
data "aws_iam_policy_document" "grafana_cloudwatch_trust_policy" {
  statement {
    resources = ["*"]
    actions = [
      "autoscaling:Describe*",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "logs:Get*",
      "logs:List*",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:Describe*",
      "logs:TestMetricFilter",
      "logs:FilterLogEvents",
      "sns:Get*",
      "sns:List*"
    ]
  }
}

module "svc_role_grafana_cloudwatch" {
  source = "../../../odc_k8s_service_account_role"

  # Default Tags
  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment

  #OIDC
  oidc_arn = local.oidc_arn
  oidc_url = local.oidc_url

  # Additional Tags
  tags = local.tags

  service_account_role = {
    name                      = "svc-${local.cluster_id}-grafana-cloudwatch"
    service_account_namespace = "monitoring"
    service_account_name      = "*"
    policy                    = data.aws_iam_policy_document.grafana_cloudwatch_trust_policy.json
  }
}

resource "kubernetes_config_map" "grafana_cloudwatch" {
  metadata {
    name      = "grafana-cloudwatch-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    AWS_ROLE_ARN                = module.svc_role_grafana_cloudwatch.role_arn
    AWS_WEB_IDENTITY_TOKEN_FILE = "/var/run/secrets/eks.amazonaws.com/serviceaccount/token"
    AWS_REGION                  = local.region
  }
}

data "template_file" "prometheus-grafana" {
  template = file("${path.module}/config/prometheus_grafana.yaml")
  vars = {
    certificate_arn = local.certificate_arn
    domain_name     = local.domain_name

    cognito_region          = local.cognito_region
    cognito_userpool_domain = local.cognito_auth_userpool_domain
    cognito_client_id       = local.cognito_auth_userpool_grafana_client_id
    cognito_client_secret   = local.cognito_auth_userpool_grafana_client_secret

    service_account_role_arn = module.svc_role_grafana_cloudwatch.role_arn
  }
}

resource "kubernetes_secret" "prometheus_grafana" {
  metadata {
    name      = "prometheus-grafana"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "values.yaml" = data.template_file.prometheus-grafana.rendered
  }

  type = "Opaque"
}
