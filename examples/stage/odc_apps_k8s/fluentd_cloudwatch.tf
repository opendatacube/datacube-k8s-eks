data "template_file" "fluentd_cloudwatch" {
  template = file("${path.module}/config/fluentd_cloudwatch.yaml")
  vars = {
    cluster_name = local.cluster_name
    region = local.region
    role_name = "${local.cluster_name}-${local.environment}-fluentd"
  }
}

resource "kubernetes_secret" "fluentd_cloudwatch" {
  depends_on = [
    kubernetes_namespace.admin
  ]

  metadata {
    name = "fluentd-cloudwatch"
    namespace = "admin"
  }

  data = {
    "values.yaml" = data.template_file.fluentd_cloudwatch.rendered
  }

  type = "Opaque"
}