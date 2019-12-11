#Ref: https://aws.amazon.com/blogs/containers/eks-dns-at-scale-and-spikeiness/

variable "localdns_cache_enable" {
  type = bool
  description = "Apply Node-local DNS Cache pod on all cluster nodes"
  default = false
}

variable "node_dns_domain" {
  type = string
  description = "kube-dns cluster domain"
  default = "cluster.local"
}

variable "node_local_dns" {
  type = string
  description = "kube-dns local-link IP"
  default = "169.254.20.10"
}

variable "node_dns_server" {
  type = string
  description = "kube-dns service IP"
  #default = $(kubectl get svc -n kube-system kube-dns -o jsonpath='{.spec.clusterIP}')
  default = "172.20.0.10"
}

data "http" "nodelocaldns" {
  # Refernce nodelocaldns file via raw url
  url = "https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/dns/nodelocaldns/nodelocaldns.yaml"
}

data "null_data_source" "dns_domain" {
  inputs = {
    # Substitute __PILLAR__DNS__DOMAIN__ variable with node_dns_domain variable
    text = replace("${data.http.nodelocaldns.body}", "__PILLAR__DNS__DOMAIN__", "${var.node_dns_domain}")
  }
}

data "null_data_source" "local_dns" {
  inputs = {
    # Substitute __PILLAR__LOCAL__DNS__ variable with node_local_dns variable
    text = replace("${data.null_data_source.dns_domain.outputs["text"]}", "__PILLAR__LOCAL__DNS__", "${var.node_local_dns}")
  }
}

data "template_file" "localdns_template" {
  # Substitute __PILLAR__DNS__SERVER__ variable with node_dns_server variable
  template = replace("${data.null_data_source.local_dns.outputs["text"]}", "__PILLAR__DNS__SERVER__", "${var.node_dns_server}")
}

resource "null_resource" "localdns_cache" {
  count    = var.localdns_cache_enable ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl apply -f - <<EOF\n${data.template_file.localdns_template.rendered}\nEOF"
  }

  provisioner "local-exec" {
    when = "destroy"
    command = "kubectl delete -f - <<EOF\n${data.template_file.localdns_template.rendered}\nEOF"
  }
}
