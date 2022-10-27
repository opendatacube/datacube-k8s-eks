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

  # Use a dynamic tag block rather than tags = [<list of tags>] to workaround this issue https://github.com/hashicorp/terraform-provider-aws/issues/14085
  dynamic "tag" {
    for_each = merge(
      {
        Name        = "${var.node_group_name}-${aws_launch_template.node.id}-nodes"
        environment = var.environment
        namespace   = var.namespace
        owner       = var.owner

        "k8s.io/cluster-autoscaler/${aws_eks_cluster.eks.id}"    = "owned"
        "k8s.io/cluster-autoscaler/enabled"                      = "true"
        "k8s.io/cluster-autoscaler/node-template/label/nodetype" = "ondemand"
        "kubernetes.io/cluster/${aws_eks_cluster.eks.id}"        = "owned"
      },
      var.tags,
      var.node_extra_tags
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
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

  # Use a dynamic tag block rather than tags = [<list of tags>] to workaround this issue https://github.com/hashicorp/terraform-provider-aws/issues/14085
  dynamic "tag" {
    for_each = merge(
      {
        Name        = "${var.node_group_name}-${aws_launch_template.spot[0].id}-spot"
        environment = var.environment
        namespace   = var.namespace
        owner       = var.owner

        "k8s.io/cluster-autoscaler/${aws_eks_cluster.eks.id}"    = "owned"
        "k8s.io/cluster-autoscaler/enabled"                      = "true"
        "k8s.io/cluster-autoscaler/node-template/label/nodetype" = "spot"
        "kubernetes.io/cluster/${aws_eks_cluster.eks.id}"        = "owned"
      },
      var.tags,
      var.node_extra_tags
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  # Don't break cluster autoscaler
  suspended_processes = ["AZRebalance"]

  depends_on = [aws_launch_template.spot]
}

