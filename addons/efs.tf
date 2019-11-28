variable "efs_enabled" {
    default     = false
    description = "Creates an encrypted EFS and connects it to the worker nodes"
}

# Find Worker Node SG
data "aws_security_group" "selected" {
  count = var.efs_enabled ? 1 : 0
  name  = "${var.cluster_name}-node"
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

resource "aws_security_group" "ingress-efs" {
   count  = var.efs_enabled ? 1 : 0
   name   = "${var.cluster_name}-efs"
   vpc_id = element(tolist(data.aws_vpcs.vpcs[0].ids), 0)

   # NFS
   ingress {
     security_groups = ["${data.aws_security_group.efs[0].id}"]
     from_port       = 2049
     to_port         = 2049
     protocol        = "tcp"
   }

   # Terraform removes the default rule
   egress {
     security_groups = ["${data.aws_security_group.efs[0].id}"]
     from_port       = 0
     to_port         = 0
     protocol        = "-1"
   }
}

resource "aws_efs_mount_target" "efs" {
  count = var.efs_enabled ? length(data.aws_subnet_ids.private[0].ids) : 0
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = element(data.aws_subnet_ids.private[0].ids, count.index)
  security_groups = [aws_security_group.ingress-efs[0].id]

}

# Create a shared disk to reference the EFS
resource "kubernetes_persistent_volume" "example" {
  metadata {
    name = "efs-persist"
    labels = {
      source = "Terraform"
    }
  }
  spec {
    capacity = {
      # EFS scales based on usage so we set a high number we'll never actually hit
      storage = "1P"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      nfs {
          server = aws_efs_mount_target.efs[0].dns_name
          path = "/"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "efs" {
  metadata {
    name = "efs-persist"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "10G"
      }
    }
    volume_name = "${kubernetes_persistent_volume.example.metadata.0.name}"
  }
}
