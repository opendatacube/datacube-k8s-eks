locals {
  # prepare a core node ASG configuration list variable based on node_asg_zones and user_nodes in each az
  core_nodes_asgs = flatten([
    for node_asg_zone in local.node_asg_zones : [
      for core_node in local.core_nodes : {
        asg_name                = "${local.node_group_name}-${aws_launch_template.core_node[core_node.instance_type].id}-${node_asg_zone}-${core_node.node_size}-core-nodes"
        launch_template_id      = aws_launch_template.core_node[core_node.instance_type].id
        launch_template_version = aws_launch_template.core_node[core_node.instance_type].latest_version
        instance_type           = core_node.instance_type
        node_size               = core_node.node_size
        node_asg_zone           = node_asg_zone
        node_desired_capacity   = core_node.desired_nodes
        node_max_capacity       = core_node.max_nodes
        node_min_capacity       = core_node.min_nodes
        vpc_zone_identifier = [
          element(data.aws_subnet.node_subnets.*.id, index(data.aws_subnet.node_subnets.*.availability_zone, node_asg_zone))
        ]
      }
    ]
  ])

  # prepare a user node ASG configuration list variable based on node_asg_zones and user_nodes in each az
  user_nodes_asgs = flatten([
    for node_asg_zone in local.node_asg_zones : [
      for user_node in local.user_nodes : {
        asg_name                = "${local.node_group_name}-${aws_launch_template.user_node[user_node.instance_type].id}-${node_asg_zone}-${user_node.node_size}-user-nodes"
        launch_template_id      = aws_launch_template.user_node[user_node.instance_type].id
        launch_template_version = aws_launch_template.user_node[user_node.instance_type].latest_version
        instance_type           = user_node.instance_type
        node_size               = user_node.node_size
        node_asg_zone           = node_asg_zone
        node_desired_capacity   = user_node.desired_nodes
        node_max_capacity       = user_node.max_nodes
        node_min_capacity       = user_node.min_nodes
        vpc_zone_identifier = [
          element(data.aws_subnet.node_subnets.*.id, index(data.aws_subnet.node_subnets.*.availability_zone, node_asg_zone))
        ]
      }
    ]
  ])

  # prepare a spot node ASG configuration list variable based on node_asg_zones and spot_nodes in each az
  spot_nodes_asgs = flatten([
    for node_asg_zone in local.node_asg_zones : [
      for spot_node in local.spot_nodes : {
        asg_name                = "${local.node_group_name}-${aws_launch_template.spot_node[spot_node.instance_type].id}-${node_asg_zone}-${spot_node.node_size}-spot-nodes"
        launch_template_id      = aws_launch_template.spot_node[spot_node.instance_type].id
        launch_template_version = aws_launch_template.spot_node[spot_node.instance_type].latest_version
        instance_type           = spot_node.instance_type
        node_size               = spot_node.node_size
        node_asg_zone           = node_asg_zone
        node_desired_capacity   = spot_node.desired_nodes
        node_max_capacity       = spot_node.max_nodes
        node_min_capacity       = spot_node.min_nodes
        vpc_zone_identifier = [
          element(data.aws_subnet.node_subnets.*.id, index(data.aws_subnet.node_subnets.*.availability_zone, node_asg_zone))
        ]
      }
    ]
  ])
}

resource "aws_autoscaling_group" "nodes" {
  for_each            = { for user_nodes_asg in local.user_nodes_asgs : "${user_nodes_asg.node_asg_zone}.${user_nodes_asg.instance_type}" => user_nodes_asg }
  desired_capacity    = each.value.node_desired_capacity
  max_size            = each.value.node_max_capacity
  min_size            = each.value.node_min_capacity
  name                = each.value.asg_name
  vpc_zone_identifier = each.value.vpc_zone_identifier

  # Don't reset to default size every time terraform is applied
  lifecycle {
    ignore_changes        = [desired_capacity]
    create_before_destroy = true
  }

  launch_template {
    id      = each.value.launch_template_id
    version = each.value.launch_template_version
  }

  tags = [
    {
      key                 = "Name"
      value               = each.value.asg_name
      propagate_at_launch = true
    },
    {
      key                 = "environment"
      value               = local.environment
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
      key                 = "k8s.io/cluster-autoscaler/node-template/label/nodetype"
      value               = "ondemand"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/node-template/label/nodesize"
      value               = each.value.node_size
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/node-template/label/nodegroup"
      value               = local.node_group_name
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
      # https://zero-to-jupyterhub.readthedocs.io/en/latest/administrator/optimization.html#scaling-down-efficiently
      # NOTE: You may need to replace / with _ due cloud provider limitations. Both taints are tolerated by the user pods.
      key                 = "k8s.io/cluster-autoscaler/node-template/taint/hub.jupyter.org/dedicated"
      value               = "user:NoSchedule"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${local.cluster_id}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "namespace"
      value               = local.namespace
      propagate_at_launch = true
    },
    {
      key                 = "owner"
      value               = local.owner
      propagate_at_launch = true
    },
  ]

  depends_on = [aws_launch_template.user_node]
}

resource "aws_autoscaling_group" "spot_nodes" {
  for_each            = { for spot_nodes_asg in local.spot_nodes_asgs : "${spot_nodes_asg.node_asg_zone}.${spot_nodes_asg.instance_type}" => spot_nodes_asg }
  desired_capacity    = each.value.node_desired_capacity
  max_size            = each.value.node_max_capacity
  min_size            = each.value.node_min_capacity
  name                = each.value.asg_name
  vpc_zone_identifier = each.value.vpc_zone_identifier

  # Don't reset to default size every time terraform is applied
  lifecycle {
    ignore_changes        = [desired_capacity]
    create_before_destroy = true
  }

  launch_template {
    id      = each.value.launch_template_id
    version = each.value.launch_template_version
  }

  tags = [
    {
      key                 = "Name"
      value               = each.value.asg_name
      propagate_at_launch = true
    },
    {
      key                 = "environment"
      value               = local.environment
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
      key                 = "k8s.io/cluster-autoscaler/node-template/label/nodetype"
      value               = "spot"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/node-template/label/nodesize"
      value               = each.value.node_size
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/node-template/label/nodegroup"
      value               = local.node_group_name
      propagate_at_launch = true
    },
    {
      # Tag convention is documented here: https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws#scaling-a-node-group-to-0
      # https://zero-to-jupyterhub.readthedocs.io/en/latest/administrator/optimization.html#scaling-down-efficiently
      key                 = "k8s.io/cluster-autoscaler/node-template/label/hub.jupyter.org/node-purpose"
      value               = "worker"
      propagate_at_launch = true
    },
    {
      # https://zero-to-jupyterhub.readthedocs.io/en/latest/administrator/optimization.html#scaling-down-efficiently
      # NOTE: You may need to replace / with _ due cloud provider limitations. Both taints are tolerated by the user pods.
      key                 = "k8s.io/cluster-autoscaler/node-template/taint/hub.jupyter.org/dedicated"
      value               = "worker:NoSchedule"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${local.cluster_id}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "namespace"
      value               = local.namespace
      propagate_at_launch = true
    },
    {
      key                 = "owner"
      value               = local.owner
      propagate_at_launch = true
    },
  ]

  depends_on = [aws_launch_template.spot_node]
}

# Note: create a seperate node group for jupyterhub core-pods like hub, proxy and user-scheduler pods
# https://zero-to-jupyterhub.readthedocs.io/en/stable/reference.html#scheduling-corepods
resource "aws_autoscaling_group" "core_nodes" {
  for_each            = { for core_nodes_asg in local.core_nodes_asgs : "${core_nodes_asg.node_asg_zone}.${core_nodes_asg.instance_type}" => core_nodes_asg }
  desired_capacity    = each.value.node_desired_capacity
  max_size            = each.value.node_max_capacity
  min_size            = each.value.node_min_capacity
  name                = each.value.asg_name
  vpc_zone_identifier = each.value.vpc_zone_identifier

  # Don't reset to default size every time terraform is applied
  lifecycle {
    ignore_changes        = [desired_capacity]
    create_before_destroy = true
  }

  launch_template {
    id      = each.value.launch_template_id
    version = each.value.launch_template_version
  }

  tags = [
    {
      key                 = "Name"
      value               = each.value.asg_name
      propagate_at_launch = true
    },
    {
      key                 = "environment"
      value               = local.environment
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
      key                 = "k8s.io/cluster-autoscaler/node-template/label/nodetype"
      value               = "ondemand"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/node-template/label/nodesize"
      value               = each.value.node_size
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/node-template/label/nodegroup"
      value               = local.node_group_name
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/node-template/label/hub.jupyter.org/node-purpose"
      value               = "core"
      propagate_at_launch = true
    },
    {
      # https://zero-to-jupyterhub.readthedocs.io/en/latest/administrator/optimization.html#scaling-down-efficiently
      # NOTE: You may need to replace / with _ due cloud provider limitations. Both taints are tolerated by the user pods.
      key                 = "k8s.io/cluster-autoscaler/node-template/taint/hub.jupyter.org/dedicated"
      value               = "core:NoSchedule"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${local.cluster_id}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "namespace"
      value               = local.namespace
      propagate_at_launch = true
    },
    {
      key                 = "owner"
      value               = local.owner
      propagate_at_launch = true
    },
  ]

  depends_on = [aws_launch_template.core_node]
}
