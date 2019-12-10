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

variable "config_output_path" {
  description = "Where to save the Kubectl config file (if `write_kubeconfig = true`). Assumed to be a directory if the value ends with a forward slash `/`."
  type        = string
  default     = "./"
}

variable "write_nodelocaldns_config" {
  description = "Whether to write a Kubectl config file containing the nodelocaldns configuration. Saved to `var.config_output_path`."
  type        = bool
  default     = true
}

data "template_file" "localdns_template" {
  template = "${file("${path.module}/config/nodelocaldns.yaml")}"
  vars = {
    PILLAR__DNS__DOMAIN = "${var.node_dns_domain}"
    PILLAR__LOCAL__DNS = "${var.node_local_dns}"
    PILLAR__DNS__SERVER = "${var.node_dns_server}"
  }
}

data "local_file" "localdnscache_config" {
  content  = data.template_file.localdns_template.rendered
  filename = substr(var.config_output_path, -1, 1) == "/" ? "${var.config_output_path}localdnscache_config_${var.cluster_name}" : var.config_output_path
}


resource "null_resource" "localdns_cache" {
  count    = var.localdns_cache_enable && var.write_nodelocaldns_config ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl apply -f - <<EOF\n${data.local_file.localdnscache_config.content}\nEOF"
  }

  provisioner "local-exec" {
    when = "destroy"
    command = "kubectl delete -f - <<EOF\n${data.local_file.localdnscache_config.content}\nEOF"
  }
}
