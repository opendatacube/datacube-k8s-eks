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
    Corefile = <<EOF
.:53 {
    log
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

  provisioner "local-exec" {
    command = "kubectl patch deployment coredns -n kube-system --patch '{\"spec\":{\"template\":{\"spec\":{\"volumes\":[{\"configMap\":{\"items\":[{\"key\":\"Corefile\",\"path\":\"Corefile\"}],\"name\":\"coredns-custom\"},\"name\":\"config-volume\"}]}}}}'"
  }
}
