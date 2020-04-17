data "aws_subnet" "node_subnets" {
  count = length(local.nodes_subnet_group)
  id    = tolist(data.aws_subnet_ids.nodes.ids)[count.index]
}

resource "aws_autoscaling_group" "nodes" {
  count            = length(local.nodes_subnet_group)
  desired_capacity = lookup(local.desired_nodes, data.aws_subnet.node_subnets[count.index].availability_zone)
  max_size         = lookup(local.max_nodes, data.aws_subnet.node_subnets[count.index].availability_zone)
  min_size         = lookup(local.min_nodes, data.aws_subnet.node_subnets[count.index].availability_zone)
  name             = "${local.node_group_name}-${aws_launch_template.user_node.id}-nodes-${count.index}"
  vpc_zone_identifier = [data.aws_subnet.node_subnets[count.index].id]

  # Don't reset to default size every time terraform is applied
  lifecycle {
    ignore_changes        = [desired_capacity]
    create_before_destroy = true
  }

  launch_template {
    id      = aws_launch_template.user_node.id
    version = aws_launch_template.user_node.latest_version
  }

  tags = [
    {
      key                 = "Name"
      value               = "${local.cluster_id}-user-node"
      propagate_at_launch = true
    },
    {
      key                 = "owner"
      value               = local.owner
      propagate_at_launch = true
    },
    {
      key                 = "namespace"
      value               = local.namespace
      propagate_at_launch = true
    },
    {
      key                 = "environment"
      value               = local.environment
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${local.cluster_id}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/${local.cluster_id}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/enabled"
      value               = "true"
      propagate_at_launch = true
    },
    {
      # Tag convention is documented here: https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws#scaling-a-node-group-to-0
      # https://zero-to-jupyterhub.readthedocs.io/en/latest/administrator/optimization.html#scaling-down-efficiently
      key                 = "k8s.io/cluster-autoscaler/node-template/label/hub.jupyter.org/node-purpose"
      value               = "user"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/node-template/taint/hub.jupyter.org/dedicated"
      value               = "user:NoSchedule"
      propagate_at_launch = true
    },
  ]

  depends_on = [aws_launch_template.user_node]
}

resource "aws_autoscaling_group" "spot_nodes" {
  count            = length(local.nodes_subnet_group)
  desired_capacity = lookup(local.spot_desired_nodes, data.aws_subnet.node_subnets[count.index].availability_zone)
  max_size         = lookup(local.spot_max_nodes, data.aws_subnet.node_subnets[count.index].availability_zone)
  min_size         = lookup(local.spot_min_nodes, data.aws_subnet.node_subnets[count.index].availability_zone)
  name             = "${local.node_group_name}-${aws_launch_template.user_node.id}-spot-nodes-${count.index}"
  vpc_zone_identifier = [data.aws_subnet.node_subnets[count.index].id]

  # Don't reset to default size every time terraform is applied
  lifecycle {
    ignore_changes        = [desired_capacity]
    create_before_destroy = true
  }

  # Refer: https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#mixed_instances_policy-1
  mixed_instances_policy {
    instances_distribution {
      spot_allocation_strategy = "lowest-price"
      spot_max_price = local.spot_max_price
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.worker_node.id
        version = aws_launch_template.worker_node.latest_version
      }
    }
  }

  tags = [
    {
      key                 = "Name"
      value               = "${local.node_group_name}-${aws_launch_template.worker_node.id}-spot-nodes-${count.index}"
      propagate_at_launch = true
    },
    {
      key                 = "owner"
      value               = local.owner
      propagate_at_launch = true
    },
    {
      key                 = "namespace"
      value               = local.namespace
      propagate_at_launch = true
    },
    {
      key                 = "environment"
      value               = local.environment
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${local.cluster_id}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/${local.cluster_id}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/enabled"
      value               = "true"
      propagate_at_launch = true
    },
    # Tag convention is documented here: https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws#scaling-a-node-group-to-0
    # https://zero-to-jupyterhub.readthedocs.io/en/latest/administrator/optimization.html#scaling-down-efficiently
    {
      key                 = "k8s.io/cluster-autoscaler/node-template/label/hub.jupyter.org/node-purpose"
      value               = "worker"
      propagate_at_launch = true
    },
    {
      # NOTE: You can replace `/` with `_`. Both taints are tolerated by the user pods.
      key                 = "k8s.io/cluster-autoscaler/node-template/taint/hub.jupyter.org/dedicated"
      value               = "worker:NoSchedule"
      propagate_at_launch = true
    },
  ]

  depends_on = [aws_launch_template.worker_node]
}

