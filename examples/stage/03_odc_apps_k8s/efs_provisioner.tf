resource "aws_efs_file_system" "user_storage" {
  # Creation token is optional and needs to be unique. terraform will create a value for us.

  tags = merge(
    {
      Name        = "${local.cluster_id}-efs-storage"
      owner       = local.owner
      namespace   = local.namespace
      environment = local.environment
    },
    local.tags
  )

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

resource "aws_efs_mount_target" "user_storage" {
  count = length(
    data.aws_eks_cluster.cluster.vpc_config[0].subnet_ids,
  )
  file_system_id = aws_efs_file_system.user_storage.id
  subnet_id = element(
    tolist(data.aws_eks_cluster.cluster.vpc_config[0].subnet_ids),
    count.index,
  )
  security_groups = [aws_security_group.efs.id]
}

resource "aws_security_group" "efs" {
  name        = "${local.cluster_id}-efs-sg"
  description = "allow NFS traffic from the EKS node and master sg"
  vpc_id      = data.aws_eks_cluster.cluster.vpc_config[0].vpc_id

  ingress {
    from_port = "2049"
    to_port   = "2049"
    protocol  = "tcp"
    security_groups = concat(
      tolist(data.aws_eks_cluster.cluster.vpc_config[0].security_group_ids),
      [local.node_security_group]
    )
  }

  tags = merge(
    {
      Name        = "${local.cluster_id}-efs-sg"
      owner       = local.owner
      namespace   = local.namespace
      environment = local.environment
    },
    local.tags
  )
}

output "efs_provisoner_fsid" {
  value = aws_efs_file_system.user_storage.id
}

data "template_file" "efs_provisioner" {
  template = file("${path.module}/config/efs_provisioner.yaml")
  vars = {
    service_account_arn = module.svc_role_efs_provisioner.role_arn
    efsFileSystemId     = aws_efs_file_system.user_storage.id
    awsRegion           = local.region
    environment         = local.environment
    path                = "/"
    dnsName             = aws_efs_file_system.user_storage.dns_name
  }
}

resource "kubernetes_secret" "efs_provisioner" {
  metadata {
    name      = "efs-provisioner"
    namespace = kubernetes_namespace.admin.metadata[0].name
  }

  data = {
    "values.yaml" = data.template_file.efs_provisioner.rendered
  }

  type = "Opaque"
}

# Get IAM policy for EFS
data "aws_iam_policy" "efs_ro" {
  arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemReadOnlyAccess"
}

# cluster efs-provisioner service account role
module "svc_role_efs_provisioner" {
  source = "../../../odc_k8s_service_account_role"

  # Default Tags
  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment

  #OIDC
  oidc_arn = local.oidc_arn
  oidc_url = local.oidc_url

  # Additional Tags
  tags = local.tags

  service_account_role = {
    name                      = "svc-${local.cluster_id}-efs-provisioner"
    service_account_namespace = "admin"
    service_account_name      = "*"
    policy                    = data.aws_iam_policy.efs_ro.policy
  }
}
