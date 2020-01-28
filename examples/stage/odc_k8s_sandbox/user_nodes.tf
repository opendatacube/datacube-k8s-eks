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
      key                 = "Owner"
      value               = local.owner
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

