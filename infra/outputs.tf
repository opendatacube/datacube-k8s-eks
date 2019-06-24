output "kubeconfig" {
  value     = module.eks.kubeconfig
  sensitive = true
}

output "cluster_name" {
  value = var.cluster_name
}

output "cluster_role" {
  value = module.eks.user_role_arn
}

output "region" {
  value = var.region
}

output "database_credentials" {
  value = <<EOF
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: ${var.cluster_name}
  namespace: default
data:
  postgres-username: ${base64encode(module.db.db_admin_username)} 
  postgres-password: ${base64encode(module.db.db_admin_password)} 
EOF


  sensitive = true
}

output "coredns_config" {
  value = <<EOF
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health
        rewrite name database.local ${module.db.db_hostname}
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          pods insecure
          upstream
          fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        proxy . /etc/resolv.conf
        cache 30
    }
kind: ConfigMap
metadata:
  labels:
    eks.amazonaws.com/component: coredns
    k8s-app: kube-dns
  name: coredns
  namespace: kube-system

EOF

}

data "aws_caller_identity" "current" {
}

output "user_profile" {
description = "You can assume this role to manage the cluster"

value = <<EOF


[profile ${var.cluster_name}]
source_profile = default
role_arn = "${module.eks.user_role_arn}"
EOF


sensitive = true
}

