data "aws_subnet" "nodes_subnet" {
  count = length(local.nodes_subnet_group)
  id    = tolist(data.aws_subnet_ids.nodes.ids)[count.index]
}

resource "aws_autoscaling_group" "nodes" {
  count            = local.nodes_enabled ? length(local.nodes_subnet_group) : 0
  desired_capacity = lookup(local.desired_nodes, data.aws_subnet.nodes_subnet[count.index].availability_zone)
  max_size         = lookup(local.max_nodes, data.aws_subnet.nodes_subnet[count.index].availability_zone)
  min_size         = lookup(local.min_nodes, data.aws_subnet.nodes_subnet[count.index].availability_zone)
  name             = "${local.node_group_name}-${aws_launch_template.user_node[0].id}-nodes-${count.index}"
  vpc_zone_identifier = [data.aws_subnet.nodes_subnet[count.index].id]

  # Don't reset to default size every time terraform is applied
  lifecycle {
    ignore_changes        = [desired_capacity]
    create_before_destroy = true
  }

  launch_template {
    id      = aws_launch_template.user_node[0].id
    version = aws_launch_template.user_node[0].latest_version
  }

  tags = [
    {
      key                 = "Name"
      value               = "${local.node_group_name}-${aws_launch_template.user_node[0].id}-nodes-${count.index}"
      propagate_at_launch = true
    },
    {
      key                 = "Owner"
      value               = local.owner
      propagate_at_launch = true
    },
    {
      key                 = "Namespace"
      value               = local.namespace
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = local.environment
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${local.cluster_id}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/enabled"
      value               = "true"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/${local.cluster_id}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/node-template/label/nodetype"
      value               = local.node_type
      propagate_at_launch = true
    },
  ]

  depends_on = [aws_launch_template.user_node]
}

resource "aws_autoscaling_group" "spot_nodes" {
  count            = local.spot_nodes_enabled ? length(local.nodes_subnet_group) : 0
  desired_capacity = lookup(local.min_spot_nodes, data.aws_subnet.nodes_subnet[count.index].availability_zone)
  max_size         = lookup(local.max_spot_nodes, data.aws_subnet.nodes_subnet[count.index].availability_zone)
  min_size         = lookup(local.min_spot_nodes, data.aws_subnet.nodes_subnet[count.index].availability_zone)
  name             = "${local.node_group_name}-${aws_launch_template.user_spot_node[0].id}-spot-${count.index}"
  vpc_zone_identifier = [data.aws_subnet.nodes_subnet[count.index].id]

  # Don't reset to default size every time terraform is applied
  lifecycle {
    ignore_changes        = [desired_capacity]
    create_before_destroy = true
  }

  launch_template {
    id      = aws_launch_template.user_spot_node[0].id
    version = aws_launch_template.user_spot_node[0].latest_version
  }

  tags = [
    {
      key                 = "Name"
      value               = "${local.node_group_name}-${aws_launch_template.user_spot_node[0].id}-spot-${count.index}"
      propagate_at_launch = true
    },
    {
      key                 = "Owner"
      value               = local.owner
      propagate_at_launch = true
    },
    {
      key                 = "Namespace"
      value               = local.namespace
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = local.environment
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${local.cluster_id}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/enabled"
      value               = "true"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/${local.cluster_id}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/node-template/label/nodetype"
      value               = local.spot_node_type
      propagate_at_launch = true
    },
  ]

  depends_on = [aws_launch_template.user_spot_node]
}
