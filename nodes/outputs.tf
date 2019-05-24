output "enabled" {
  value = "${var.group_enabled}"
}

output "node_desired_counts" {
  value = "${concat(data.aws_autoscaling_group.nodes.*.desired_capacity, data.aws_autoscaling_group.spots.*.desired_capacity)}"
}