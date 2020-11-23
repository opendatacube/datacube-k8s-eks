resource "aws_autoscaling_group" "nodes" {
  desired_capacity    = var.desired_nodes
  max_size            = var.max_nodes
  min_size            = var.min_nodes
  name                = "${var.node_group_name}-${aws_launch_template.node.id}-nodes"
  vpc_zone_identifier = var.eks_subnet_ids

  # Don't reset to default size every time terraform is applied
  lifecycle {
    ignore_changes        = [desired_capacity]
    create_before_destroy = true
  }

  launch_template {
    id      = aws_launch_template.node.id
    version = aws_launch_template.node.latest_version
  }

  # Use a dyanmic tag block rather than tags = [<list of tags>] to workaround this issue https://github.com/hashicorp/terraform-provider-aws/issues/14085
  dynamic "tag" {
    for_each = concat(
      flatten([
        for key in keys(var.node_extra_tags) :
        {
          key                 = key
          value               = var.node_extra_tags[key]
          propagate_at_launch = true
        }
      ]),
      [
        {
          key                 = "Name"
          value               = "${var.node_group_name}-${aws_launch_template.node.id}-nodes"
          propagate_at_launch = true
        },
        {
          key                 = "environment"
          value               = var.environment
          propagate_at_launch = true
        },
        {
          key                 = "k8s.io/cluster-autoscaler/${aws_eks_cluster.eks.id}"
          value               = "owned"
          propagate_at_launch = true
        },
        {
          key                 = "k8s.io/cluster-autoscaler/enabled"
          value               = "true"
          propagate_at_launch = true
        },
        {
          key                 = "k8s.io/cluster-autoscaler/node-template/label/nodetype"
          value               = "ondemand"
          propagate_at_launch = true
        },
        {
          key                 = "kubernetes.io/cluster/${aws_eks_cluster.eks.id}"
          value               = "owned"
          propagate_at_launch = true
        },
        {
          key                 = "namespace"
          value               = var.namespace
          propagate_at_launch = true
        },
        {
          key                 = "owner"
          value               = var.owner
          propagate_at_launch = true
        },
    ])
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }

  # Don't break cluster autoscaler
  suspended_processes = ["AZRebalance"]

  depends_on = [aws_launch_template.node]
}

resource "aws_autoscaling_group" "spot_nodes" {
  count               = var.spot_nodes_enabled ? 1 : 0
  desired_capacity    = var.desired_nodes
  max_size            = var.max_spot_nodes
  min_size            = var.min_spot_nodes
  name                = "${var.node_group_name}-${aws_launch_template.spot[0].id}-spot"
  vpc_zone_identifier = var.eks_subnet_ids

  # Don't reset to default size every time terraform is applied
  lifecycle {
    ignore_changes        = [desired_capacity]
    create_before_destroy = true
  }

  launch_template {
    id      = aws_launch_template.spot[0].id
    version = aws_launch_template.spot[0].latest_version
  }

  # Use a dyanmic tag block rather than tags = [<list of tags>] to workaround this issue https://github.com/hashicorp/terraform-provider-aws/issues/14085
  dynamic "tag" {
    for_each = concat(
      flatten([
        for key in keys(var.node_extra_tags) :
        {
          key                 = key
          value               = var.node_extra_tags[key]
          propagate_at_launch = true
        }
      ]),
      [
        {
          key                 = "Name"
          value               = "${var.node_group_name}-${aws_launch_template.spot[0].id}-spot"
          propagate_at_launch = true
        },
        {
          key                 = "environment"
          value               = var.environment
          propagate_at_launch = true
        },
        {
          key                 = "k8s.io/cluster-autoscaler/${aws_eks_cluster.eks.id}"
          value               = "owned"
          propagate_at_launch = true
        },
        {
          key                 = "k8s.io/cluster-autoscaler/enabled"
          value               = "true"
          propagate_at_launch = true
        },
        {
          key                 = "k8s.io/cluster-autoscaler/node-template/label/nodetype"
          value               = "spot"
          propagate_at_launch = true
        },
        {
          key                 = "kubernetes.io/cluster/${aws_eks_cluster.eks.id}"
          value               = "owned"
          propagate_at_launch = true
        },
        {
          key                 = "namespace"
          value               = var.namespace
          propagate_at_launch = true
        },
        {
          key                 = "owner"
          value               = var.owner
          propagate_at_launch = true
        },
    ])
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }


  # Don't break cluster autoscaler
  suspended_processes = ["AZRebalance"]

  depends_on = [aws_launch_template.spot]
}

