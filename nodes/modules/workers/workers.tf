resource "aws_autoscaling_group" "nodes" {
  count            = var.nodes_enabled ? length(var.nodes_subnet_group) : 0
  desired_capacity = lookup(var.desired_nodes, "az_${count.index}")
  max_size         = lookup(var.max_nodes, "az_${count.index}")
  min_size         = lookup(var.min_nodes, "az_${count.index}")
  name             = "${var.node_group_name}-${aws_launch_template.node[count.index].id}-nodes-${count.index}"
  vpc_zone_identifier = [element(var.nodes_subnet_group, count.index)]

  # Don't reset to default size every time terraform is applied
  lifecycle {
    ignore_changes        = [desired_capacity]
    create_before_destroy = true
  }

  launch_template {
    id      = element(aws_launch_template.node.*.id, count.index)
    version = element(aws_launch_template.node.*.latest_version, count.index)
  }

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}-node-${count.index}"
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

  depends_on = [aws_launch_template.node]
}

# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_autoscaling_group" "spot_nodes" {
  count            = var.spot_nodes_enabled ? length(var.nodes_subnet_group) : 0
  availability_zones = [data.aws_availability_zones.available.names[count.index]]
  desired_capacity = lookup(var.min_spot_nodes, "${data.aws_availability_zones.available.names[count.index]}")
  max_size         = lookup(var.max_spot_nodes, "${data.aws_availability_zones.available.names[count.index]}")
  min_size         = lookup(var.min_spot_nodes, "${data.aws_availability_zones.available.names[count.index]}")
  name             = "${var.node_group_name}-${aws_launch_template.spot[count.index].id}-spot-${count.index}"
//  vpc_zone_identifier = [element(var.nodes_subnet_group, count.index)]

  # Don't reset to default size every time terraform is applied
  lifecycle {
    ignore_changes        = [desired_capacity]
    create_before_destroy = true
  }

  launch_template {
    id      = element(aws_launch_template.spot.*.id, count.index)
    version = element(aws_launch_template.spot.*.latest_version, count.index)
  }

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}-spot-${count.index}"
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
  
  depends_on = [aws_launch_template.spot]
}

