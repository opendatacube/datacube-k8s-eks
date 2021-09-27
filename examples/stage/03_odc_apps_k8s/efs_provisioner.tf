resource "aws_efs_file_system" "user_storage" {
  # Creation token is optional and needs to be unique. terraform will create a value for us.

  tags = {
    Name        = "${local.cluster_id}-efs-storage"
    Cluster     = local.cluster_id
    Owner       = local.owner
    Namespace   = local.namespace
    Environment = local.environment
  }

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

  tags = {
    Name        = "${local.cluster_id}-efs-sg"
    Cluster     = local.cluster_id
    Owner       = local.owner
    Namespace   = local.namespace
    Environment = local.environment
  }
}

output "efs_provisoner_fsid" {
  value = aws_efs_file_system.user_storage.id
}

data "template_file" "efs_provisioner" {
  template = file("${path.module}/config/efs_provisioner.yaml")
  vars = {
    role_name       = module.odc_role_efs-provisioner.role_name
    efsFileSystemId = aws_efs_file_system.user_storage.id
    awsRegion       = local.region
    environment     = local.environment
    path            = "/"
    dnsName         = aws_efs_file_system.user_storage.dns_name
    cluster_name    = local.cluster_id
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

module "odc_role_efs-provisioner" {
  # source = "github.com/opendatacube/datacube-k8s-eks//odc_role?ref=master"
  source = "../../../odc_role"

  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment
  cluster_id  = local.cluster_id

  role = {
    name   = "${local.cluster_id}-efs-provisioner"
    policy = data.aws_iam_policy.efs_ro.policy
  }
}
