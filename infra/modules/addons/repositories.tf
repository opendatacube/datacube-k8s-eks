data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

data "helm_repository" "incubator" {
  name = "incubator"
  url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
}

data "helm_repository" "coreos" {
  name = "coreos"
  url  = "https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/"
}

data "helm_repository" "weaveworks" {
  name = "weaveworks"
  url  = "https://weaveworks.github.io/flux"
}
