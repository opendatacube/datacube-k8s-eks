resource "aws_autoscaling_group" "nodes" {
  desired_capacity = var.desired_nodes
  max_size         = var.max_nodes
  min_size         = var.min_nodes
  name             = "${var.node_group_name}-${aws_launch_template.node.id}-nodes-0"
  vpc_zone_identifier = var.nodes_subnet_group

  # Don't reset to default size every time terraform is applied
  lifecycle {
    ignore_changes        = [desired_capacity]
    create_before_destroy = true
  }

  launch_template {
    id      = aws_launch_template.node.id
    version = aws_launch_template.node.latest_version
  }

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}-node"
      propagate_at_launch = true
    },
    {
      key                 = "owner"
      value               = var.owner
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${var.cluster_name}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/enabled"
      value               = "true"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/node-template/label/nodetype"
      value               = "ondemand"
      propagate_at_launch = true
    },
  ]

  # Don't break cluster autoscaler
  suspended_processes = ["AZRebalance"]

  depends_on = [aws_launch_template.node]
}

resource "aws_autoscaling_group" "spot_nodes" {
  count            = var.spot_nodes_enabled ? 1 : 0
  desired_capacity = var.desired_nodes
  max_size         = var.max_spot_nodes
  min_size         = var.min_spot_nodes
  name             = "${var.node_group_name}-${aws_launch_template.spot[0].id}-spot-0"
  vpc_zone_identifier = var.nodes_subnet_group

  # Don't reset to default size every time terraform is applied
  lifecycle {
    ignore_changes        = [desired_capacity]
    create_before_destroy = true
  }

  launch_template {
    id      = aws_launch_template.spot[0].id
    version = aws_launch_template.spot[0].latest_version
  }

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}-spot"
      propagate_at_launch = true
    },
    {
      key                 = "owner"
      value               = var.owner
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${var.cluster_name}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/enabled"
      value               = "true"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/node-template/label/nodetype"
      value               = "spot"
      propagate_at_launch = true
    },
  ]

  # Don't break cluster autoscaler
  suspended_processes = ["AZRebalance"]
  
  depends_on = [aws_launch_template.spot]
}

