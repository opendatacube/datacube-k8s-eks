# Worker nodes
resource "aws_autoscaling_group" "nodes" {
  count                = "${var.nodes_enabled * length(var.nodes_subnet_group) }"
  desired_capacity     = "${var.max_nodes}"
  launch_configuration = "${aws_launch_configuration.eks.name}"
  max_size             = "${var.max_nodes}"
  min_size             = "${var.min_nodes}"
  name                 = "${var.node_group_name}-${aws_launch_configuration.eks.name}-nodes-${count.index}"
  vpc_zone_identifier  = ["${element(var.nodes_subnet_group, count.index)}"]

  # Don't reset to default size every time terraform is applied
  lifecycle {
    ignore_changes        = ["desired_capacity"]
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}-nodes-${count.index}"
      propagate_at_launch = true
    },
    {
      key                 = "owner"
      value               = "${var.owner}"
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
  ]
}

resource "aws_autoscaling_group" "spot" {
  count               = "${var.spot_nodes_enabled * length(var.nodes_subnet_group) }"
  desired_capacity    = "${var.max_spot_nodes}"
  max_size            = "${var.max_spot_nodes}"
  min_size            = "${var.min_spot_nodes}"
  name                = "${var.node_group_name}-${aws_launch_template.spot.*.id[count.index]}-spot-${count.index}"
  vpc_zone_identifier = ["${element(var.nodes_subnet_group, count.index)}"]

  # Don't reset to default size every time terraform is applied
  lifecycle {
    ignore_changes        = ["desired_capacity"]
    create_before_destroy = true
  }

  launch_template {
    id      = "${aws_launch_template.spot.*.id[count.index]}"
    version = "${aws_launch_template.spot.*.latest_version[count.index]}"
  }

  # mixed_instances_policy {
  #   instances_distribution {
  #     spot_max_price = "${var.max_spot_price}"
  #   }


  #   launch_template {
  #     id      = "${aws_launch_template.spot.*.id[count.index]}"
  #     version = "${aws_launch_template.spot.*.latest_version[count.index]}"


  #     launch_template_specification {
  #       launch_template_id = "${aws_launch_template.spot.*.id[count.index]}"
  #       version            = "${aws_launch_template.spot.*.latest_version[count.index]}"
  #     }


  #     override {
  #       instance_type = "c4.4xlarge"
  #     }


  #     override {
  #       instance_type = "r4.4xlarge"
  #     }


  #     override {
  #       instance_type = "m4.4xlarge"
  #     }
  #   }
  # }

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}-spot-${count.index}"
      propagate_at_launch = true
    },
    {
      key                 = "owner"
      value               = "${var.owner}"
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
  ]
  depends_on = ["aws_launch_template.spot"]
}

resource "aws_autoscaling_group" "dask" {
  count               = "${var.dask_nodes_enabled * length(var.nodes_subnet_group) }"
  desired_capacity    = "${var.max_dask_spot_nodes}"
  max_size            = "${var.max_dask_spot_nodes}"
  min_size            = "${var.min_dask_spot_nodes}"
  name                = "${var.node_group_name}-${aws_launch_template.spot.*.id[count.index]}-dask-${count.index}"
  vpc_zone_identifier = ["${element(var.nodes_subnet_group, count.index)}"]

  # Don't reset to default size every time terraform is applied
  lifecycle {
    ignore_changes        = ["desired_capacity"]
    create_before_destroy = true
  }

  launch_template {
    id      = "${aws_launch_template.spot.*.id[count.index]}"
    version = "${aws_launch_template.spot.*.latest_version[count.index]}"
  }

  # mixed_instances_policy {
  #   instances_distribution {
  #     spot_max_price = "${var.max_spot_price}"
  #   }


  #   launch_template {
  #     launch_template_specification {
  #       launch_template_id = "${aws_launch_template.spot.*.id[count.index]}"
  #       version            = "${aws_launch_template.spot.*.latest_version[count.index]}"
  #     }


  #     override {
  #       instance_type = "c4.4xlarge"
  #     }


  #     override {
  #       instance_type = "r4.4xlarge"
  #     }


  #     override {
  #       instance_type = "m4.4xlarge"
  #     }
  #   }
  # }

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}-dask-${count.index}"
      propagate_at_launch = true
    },
    {
      key                 = "owner"
      value               = "${var.owner}"
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
  ]
  depends_on = ["aws_launch_template.spot"]
}
