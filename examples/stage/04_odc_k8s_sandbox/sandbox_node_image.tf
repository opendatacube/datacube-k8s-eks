# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform template file to simplify Base64 encoding this
# information into the AutoScaling Launch Template.
# More information on self-managed nodes: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html

data "aws_ami" "user_node" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.cluster_version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452", "877085696533"] # Amazon EKS AMI Account ID
}

locals {
  # return first non-empty value
  ami_id = coalesce(local.ami_image_id, data.aws_ami.user_node.id)
}

data "template_file" "core_node_userdata" {
  for_each = { for core_node in local.core_nodes : core_node.instance_type => core_node }
  template = file("${path.module}/config/node_userdata.tpl.sh")
  vars = {
    cluster_id            = local.cluster_id
    endpoint              = local.endpoint
    certificate_authority = local.certificate_authority

    node_group   = local.node_group_name
    node_type    = "ondemand"
    node_size    = each.value.node_size
    node_purpose = "core"
  }
}

data "template_file" "spot_node_userdata" {
  for_each = { for spot_node in local.spot_nodes : spot_node.instance_type => spot_node }
  template = file("${path.module}/config/node_userdata.tpl.sh")
  vars = {
    cluster_id            = local.cluster_id
    endpoint              = local.endpoint
    certificate_authority = local.certificate_authority

    node_group   = local.node_group_name
    node_type    = "spot"
    node_size    = each.value.node_size
    node_purpose = "worker"
  }
}

data "template_file" "user_node_userdata" {
  for_each = { for user_node in local.user_nodes : user_node.instance_type => user_node }
  template = file("${path.module}/config/node_userdata.tpl.sh")
  vars = {
    cluster_id            = local.cluster_id
    endpoint              = local.endpoint
    certificate_authority = local.certificate_authority

    node_group   = local.node_group_name
    node_type    = "ondemand"
    node_size    = each.value.node_size
    node_purpose = "user"
  }
}

resource "aws_launch_template" "core_node" {
  for_each               = { for core_node in local.core_nodes : core_node.instance_type => core_node }
  name_prefix            = "${local.cluster_id}-${local.node_group_name}-${each.value.instance_type}-core-nodes"
  image_id               = local.ami_id
  user_data              = base64encode(data.template_file.core_node_userdata[each.key].rendered)
  instance_type          = each.value.instance_type
  vpc_security_group_ids = [local.node_security_group]

  iam_instance_profile {
    # TODO this is the naming convention for this IAM profile for datacube-k8s-eks but it should probably be looked up
    name = "${local.cluster_id}-node"
  }

  lifecycle {
    create_before_destroy = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = each.value.ebs_volume_size
    }
  }
}

resource "aws_launch_template" "user_node" {
  for_each               = { for user_node in local.user_nodes : user_node.instance_type => user_node }
  name_prefix            = "${local.cluster_id}-${local.node_group_name}-${each.value.instance_type}-user-nodes"
  image_id               = local.ami_id
  user_data              = base64encode(data.template_file.user_node_userdata[each.key].rendered)
  instance_type          = each.value.instance_type
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
      volume_size = each.value.ebs_volume_size
    }
  }
}

resource "aws_launch_template" "spot_node" {
  for_each               = { for spot_node in local.spot_nodes : spot_node.instance_type => spot_node }
  name_prefix            = "${local.cluster_id}-${local.node_group_name}-${each.value.instance_type}-spot-nodes"
  image_id               = local.ami_id
  user_data              = base64encode(data.template_file.spot_node_userdata[each.key].rendered)
  instance_type          = each.value.instance_type
  vpc_security_group_ids = [local.node_security_group]

  iam_instance_profile {
    # TODO this is the naming convention for this IAM profile for datacube-k8s-eks but it shoudl probably be looked up
    name = "${local.cluster_id}-node"
  }

  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = each.value.max_price
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = each.value.ebs_volume_size
    }
  }
}
