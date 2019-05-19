data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
  depends_on = ["null_resource.helm_init_client"]
}

data "helm_repository" "incubator" {
  name = "incubator"
  url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
  depends_on = ["null_resource.repo_add_incubator"]
}

data "helm_repository" "coreos" {
  name = "coreos"
  url  = "https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/"
  depends_on = ["null_resource.repo_add_coreos"]
}

data "helm_repository" "weaveworks" {
  name = "weaveworks"
  url  = "https://weaveworks.github.io/flux"
  depends_on = ["null_resource.repo_add_weaveworks"]
}


# Until patched, Helm must be inited on the client
resource "null_resource" "helm_init_client" {
    provisioner "local-exec" {
      command = "helm init --client-only"
  }
  triggers = {
    uuid = "${uuid()}"
  }
}

# Helm repo data sources still require to be added through `helm repo add`
resource "null_resource" "repo_add_incubator" {
  provisioner "local-exec" {
    command = "helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com"
  }
  triggers = {
    id = "${null_resource.helm_init_client.id}"
  }
}

resource "null_resource" "repo_add_coreos" {
  provisioner "local-exec" {
    command = "helm repo add coreos https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/"
  }
  triggers = {
    id = "${null_resource.helm_init_client.id}"
  }
}

resource "null_resource" "repo_add_weaveworks" {
  provisioner "local-exec" {
    command = "helm repo add weaveworks https://weaveworks.github.io/flux"
  }
  triggers = {
    id = "${null_resource.helm_init_client.id}"
  }
}