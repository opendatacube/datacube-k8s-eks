variable "efs_enabled" {
    default     = false
    description = "Creates an encrypted EFS and connects it to the worker nodes"
}

variable "efs_pvc_namespace" {
    default     = "default"
    type        = string
    description = "The namespace to automatically create the efs persistant volume claim"
}

# Find Worker Node SG
data "aws_security_group" "worker" {
  count = var.efs_enabled ? 1 : 0
  name  = "terraform-eks-eks-node"
  tags = {
    Name = "${var.cluster_name}-node"
  }

}

# Find Network info
data "aws_vpcs" "vpcs" {
  count = var.efs_enabled ? 1 :0

  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

data "aws_subnet_ids" "private" {
  count  = var.efs_enabled ? 1 :0
  vpc_id = element(tolist(data.aws_vpcs.vpcs[0].ids), 0)

  tags = {
    SubnetType = "Private"
  }
}

# Create and EFS
resource "aws_efs_file_system" "efs" {
  count          = var.efs_enabled ? 1 : 0
  creation_token = var.cluster_name
  encrypted      = true

  tags = {
    owner      = var.owner
    cluster    = var.cluster_name
    Created_by = "terraform"
    Name       = "${var.cluster_name}_efs"
  }
}

# Create a SG so the nodes can talk to the EFS
resource "aws_security_group" "ingress-efs" {
   count  = var.efs_enabled ? 1 : 0
   name   = "${var.cluster_name}-efs"
   vpc_id = element(tolist(data.aws_vpcs.vpcs[0].ids), 0)

   # NFS
   ingress {
     security_groups = [data.aws_security_group.worker[0].id]
     from_port       = 2049
     to_port         = 2049
     protocol        = "tcp"
   }

   # Terraform removes the default rule
   egress {
     security_groups = [data.aws_security_group.worker[0].id]
     from_port       = 0
     to_port         = 0
     protocol        = "-1"
   }
}

# Mount targets so each AZ can access the EFS
resource "aws_efs_mount_target" "efs" {
  count = var.efs_enabled ? length(data.aws_subnet_ids.private[0].ids) : 0
  file_system_id  = aws_efs_file_system.efs[0].id
  subnet_id       = element(tolist(data.aws_subnet_ids.private[0].ids), count.index)
  security_groups = [aws_security_group.ingress-efs[0].id]

}

# We template the values instead of using a yaml, this should probably be cleaned up later to be consistent
data "template_file" "efs-provisioner_config" {
  count          = var.efs_enabled ? 1 : 0
  template = file("config/efs-provisioner.tpl")
  vars = {
    efsFileSystemId = aws_efs_file_system.efs[0].id
    awsRegion       = var.region
    path            = "/"
    dnsName         = aws_efs_file_system.efs[0].dns_name
    iam_role_name   = aws_iam_role.efs-provisioner[0].name
  }
}

# The efs-provisioner will create the k8s components we need
resource "helm_release" "efs-provisioner" {
  count          = var.efs_enabled ? 1 : 0
  name      = "efs-provisioner"
  namespace = "kube-system"
  chart     = "stable/efs-provisioner"
  values = [
    data.template_file.efs-provisioner_config[0].rendered,
  ]
  depends_on = [aws_efs_mount_target.efs]
}

# EFS PVC using kubernetes provider
resource "kubernetes_persistent_volume_claim" "efs" {
  count  = var.efs_enabled ? 1 :0
  metadata {
    name      = "efs"
    namespace = var.efs_pvc_namespace
    annotations = {
      "volume.beta.kubernetes.io/storage-class" = "efs" # this annotation has been deprecated but it appears to be necessary for cluster-autoscaler to function with PVC. Terraform might complain with some versions of k8s provider
    }
  }
  spec {
    storage_class_name = "efs"
    access_modes       = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Mi"
      }
    }
  }
}

# IAM policy 
# At a minimum require read access to EFS  associated with user volumes
# used by efs-provisioner helm chart
resource "aws_iam_role" "efs-provisioner" {
  count  = var.efs_enabled ? 1 :0
  name = "${var.cluster_name}-efs-provisioner"
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

data "aws_iam_policy" "efs-ro" {
  count  = var.efs_enabled ? 1 :0
  arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemReadOnlyAccess"
}

resource "aws_iam_role_policy" "efs-provisioner" {
  count  = var.efs_enabled ? 1 :0
  name = "${var.cluster_name}-efs-provisioner"
  role = aws_iam_role.efs-provisioner[0].id
  policy = data.aws_iam_policy.efs-ro[0].policy
}
