data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.eks_cluster_version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  # return first non-empty value
  ami_id = "${coalesce(var.ami_image_id, data.aws_ami.eks-worker.id)}"

  eks-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${var.api_endpoint}' --b64-cluster-ca '${var.cluster_ca}' '${var.cluster_name}' \
--kubelet-extra-args \
  "--node-labels=cluster=${var.cluster_name},nodegroup=${var.node_group_name} \
   --cloud-provider=aws" 
USERDATA
}

resource "aws_launch_configuration" "eks" {
  count                       = "${var.nodes_enabled}"
  associate_public_ip_address = false
  iam_instance_profile        = "${var.node_instance_profile}"
  image_id                    = "${local.ami_id}"
  instance_type               = "${var.default_worker_instance_type}"
  name_prefix                 = "${var.cluster_name}"
  security_groups             = ["${var.node_security_group}"]
  user_data_base64            = "${base64encode(local.eks-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "spot" {
  count       = "${var.nodes_enabled * length(var.nodes_subnet_group) }"
  name_prefix = "${var.cluster_name}"
  image_id    = "${data.aws_ami.eks-worker.id}"

  #vpc_security_group_ids = ["${var.node_security_group}"]
  user_data = "${base64encode(local.eks-node-userdata)}"

  #this will be overwritten later
  instance_type = "${var.default_worker_instance_type}"

  iam_instance_profile {
    name = "${var.node_instance_profile}"
  }

  network_interfaces {
    subnet_id                   = "${var.nodes_subnet_group[count.index]}"
    associate_public_ip_address = false
    security_groups             = ["${var.node_security_group}"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
