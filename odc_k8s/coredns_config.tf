resource "kubernetes_config_map" "coredns_custom" {
  metadata {
    name = "coredns-custom"
    namespace = "kube-system"
    labels = {
      "eks.amazonaws.com/component": "coredns"
      "k8s-app": "kube-dns"
    }
  }

  data = {
    Corefile = <<-EOF
  .:53 {
      errors
      health
      rewrite name database.local ${var.db_hostname}
      kubernetes cluster.local in-addr.arpa ip6.arpa {
        pods insecure
        upstream
        fallthrough in-addr.arpa ip6.arpa
      }
      prometheus :9153
      proxy . /etc/resolv.conf
      cache 30
      loop
      reload
      loadbalance
  }
  EOF
  }

  # TODO: Refactor issue: kubectl is not available on Terraform Cloud.Is this line still necessary? It was originally requried to kick the pods to use the new config during update but this will likely be handled upstream by the k8s CD environment after refactor
  # provisioner "local-exec" {
  #   command = "kubectl patch deployment coredns -n kube-system --patch '{\"spec\":{\"template\":{\"spec\":{\"volumes\":[{\"configMap\":{\"items\":[{\"key\":\"Corefile\",\"path\":\"Corefile\"}],\"name\":\"coredns-custom\"},\"name\":\"config-volume\"}]}}}}'"
  # }
}