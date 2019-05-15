output "config_map_aws_auth" {
  value     = "${module.eks.config_map_aws_auth}"
  sensitive = true
}

output "kubeconfig" {
  value     = "${module.eks.kubeconfig}"
  sensitive = true
}

output "current_nodegroup" {
  value = "${var.green_nodes_enabled ? "green" : "blue"}"
}

output "cluster_name" {
  value = "${var.cluster_name}"
}

output "region" {
  value = "${var.region}"
}

output "cluster_defaults" {
  value = <<EOF
global:
  domain: services.${var.app_zone}
  clusterSecret: ${var.cluster_name}
  externalDatabase:
    host: ${module.db.db_dns}
    port: ${module.db.port}
    credsFromSecret: ${var.cluster_name}
EOF

  sensitive = true
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
  postgres-username: ${base64encode(module.db.db_username)} 
  postgres-password: ${base64encode(module.db.db_password)} 
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
        rewrite name database.local ${module.db.db_dns}
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

data "aws_caller_identity" "current" {}

output "user_profile" {
  description = "You can assume this role to manage the cluster"

  value = <<EOF


[profile ${var.cluster_name}]
source_profile = default
role_arn = "${module.eks.user_role_arn}"
mfa_serial = arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/<your user name>
EOF

  sensitive = true
}
