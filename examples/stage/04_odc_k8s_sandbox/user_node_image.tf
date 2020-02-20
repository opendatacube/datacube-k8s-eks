data "aws_ami" "user_node" {
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
  ami_id = coalesce(local.ami_image_id, data.aws_ami.user_node.id)

  eks-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
# Get instance and ami id from the aws ec2 metadate endpoint
id=$(curl http://169.254.169.254/latest/meta-data/instance-id -s)
ami=$(curl http://169.254.169.254/latest/meta-data/ami-id -s)
/etc/eks/bootstrap.sh --apiserver-endpoint '${local.endpoint}' --b64-cluster-ca '${local.certificate_authority}' '${local.cluster_id}' \
--kubelet-extra-args \
  "--node-labels=cluster=${local.cluster_id},nodegroup="users",nodetype="ondemand",instance-id=$id,ami-id=$ami,"hub.jupyter.org/node-purpose=user" \
   --register-with-taints="hub.jupyter.org/dedicated=user:NoSchedule" \
   --cloud-provider=aws"
USERDATA

}

resource "aws_launch_template" "user_node" {
  name_prefix            = "user-nodes-${local.cluster_id}"
  image_id               = local.ami_id
  user_data              = base64encode(local.eks-node-userdata)
  instance_type          = local.user_node_instance_type
  vpc_security_group_ids = [local.node_security_group]

  iam_instance_profile {
    # TODO this is the naming convention for this IAM profile for datacube-k8s-eks but it shoudl probably be looked up
    name = "${local.cluster_id}-node"
  }

  lifecycle {
    create_before_destroy = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = local.user_node_volume_size
    }
  }
}

