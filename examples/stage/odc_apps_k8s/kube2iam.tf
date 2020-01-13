data "template_file" "kube2iam" {
  template = "${file("${path.module}/config/kube2iam.yaml")}"
  vars = {
    account_id = "${data.aws_caller_identity.current.account_id}"
  }
}

resource "kubernetes_secret" "kube2iam" {
  metadata {
    name = "kube2iam"
    namespace = "kube-system"
  }

  data = {
    "values.yaml" = "${data.template_file.kube2iam.rendered}"
  }

  type = "Opaque"
}