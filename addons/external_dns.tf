# ======================================
# External DNS
variable "external_dns_enabled" {
  default = false
}

resource "helm_release" "external-dns" {
    count      = "${var.external_dns_enabled ? 1 : 0}"
    name       = "external-dns"
    repository = "${data.helm_repository.stable.metadata.0.name}"
    chart      = "stable/external-dns"
    namespace = "ingress-controller"

    set {
      name = "podAnnotations.iam\\.amazonaws\\.com/role"
      value = "${var.cluster_name}-external-dns"
    }

    values = [<<EOF
## This controls which types of resource external-dns should 'watch' for new
## DNS entries.
sources:
  - service
  - ingress
## Limit possible target zones by domain suffixes (optional)
domainFilters: ["${var.domain_name}"]
## The DNS provider where the DNS records will be created (options: aws, google, inmemory, azure, rfc2136 )
provider: aws
## Modify how DNS records are sychronized between sources and providers (options: sync, upsert-only )
policy: sync
# Registry to use for ownership (txt or noop)
registry: "txt"
# When using the TXT registry, a name that identifies this instance of ExternalDNS
txtOwnerId: "${var.txt_owner_id}"
# Create rbac resources
rbac:
  ## If true, create & use RBAC resources
  ##
  create: true
  # Beginning with Kubernetes 1.8, the api is stable and v1 can be used.
  apiVersion: v1

  ## Ignored if rbac.create is true
  ##
  serviceAccountName: external-dns
EOF
    ]

    # Uses kube2iam for credentials
    depends_on = ["helm_release.kube2iam",
                  "aws_iam_role.external_dns",
                  "aws_iam_role_policy.external_dns",
                  "kubernetes_namespace.ingress-controller",
                  "kubernetes_service_account.tiller", 
                  "kubernetes_cluster_role_binding.tiller_clusterrolebinding",
                  "null_resource.helm_init_client"]
}

resource "aws_iam_role" "external_dns" {
  count = "${var.external_dns_enabled}"
  name  = "${var.cluster_name}-external-dns"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/nodes.${var.cluster_name}"
        },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "external_dns" {
  count = "${var.external_dns_enabled}"
  name  = "${var.cluster_name}-external-dns"
  role  = "${aws_iam_role.external_dns.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}
