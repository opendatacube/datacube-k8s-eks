data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.eks_cluster_version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Template.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  # return first non-empty value
  ami_id = coalesce(local.ami_image_id, data.aws_ami.eks-worker.id)

  eks-node-userdata = <<-USERDATA
    #!/bin/bash
    set -o xtrace
    # Get instance and ami id from the aws ec2 metadate endpoint
    id=$(curl http://169.254.169.254/latest/meta-data/instance-id -s)
    ami=$(curl http://169.254.169.254/latest/meta-data/ami-id -s)
    /etc/eks/bootstrap.sh --apiserver-endpoint '${local.endpoint}' --b64-cluster-ca '${local.certificate_authority}' '${local.cluster_id}' \
    --kubelet-extra-args \
      "--node-labels=cluster=${local.cluster_id},nodegroup=${local.node_group_name},nodetype=${local.node_type},instance-id=$id,ami-id=$ami \
       --cloud-provider=aws"
    ${local.extra_userdata}
  USERDATA

  eks-spot-userdata = <<-USERDATA
    #!/bin/bash
    set -o xtrace
    # Get instance and ami id from the aws ec2 metadate endpoint
    id=$(curl http://169.254.169.254/latest/meta-data/instance-id -s)
    ami=$(curl http://169.254.169.254/latest/meta-data/ami-id -s)
    /etc/eks/bootstrap.sh --apiserver-endpoint '${local.endpoint}' --b64-cluster-ca '${local.certificate_authority}' '${local.cluster_id}' \
    --kubelet-extra-args \
      "--node-labels=cluster=${local.cluster_id},nodegroup=${local.node_group_name},nodetype=${local.spot_node_type},instance-id=$id,ami-id=$ami \
       --cloud-provider=aws"
    ${local.extra_userdata}
  USERDATA

}

resource "aws_launch_template" "node" {
  count = local.nodes_enabled ? 1 : 0
  name_prefix = local.node_group_name
  image_id = local.ami_id
  user_data = base64encode(local.eks-node-userdata)
  instance_type = local.default_worker_instance_type

  iam_instance_profile {
    name = "${local.cluster_id}-node"
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [local.node_security_group]
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = local.volume_size
    }
  }
}

resource "aws_launch_template" "spot" {
  count = local.spot_nodes_enabled ? 1 : 0
  name_prefix = local.node_group_name
  image_id = local.ami_id
  user_data = base64encode(local.eks-spot-userdata)
  instance_type = local.default_worker_instance_type

  iam_instance_profile {
    name = "${local.cluster_id}-node"
  }

  instance_market_options {
    market_type = "spot"
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [local.node_security_group]
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = local.spot_volume_size
    }
  }

}