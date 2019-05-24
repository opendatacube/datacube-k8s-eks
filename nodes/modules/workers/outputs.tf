output "ami_image_id" {
  value = "${local.ami_id}"
}

output "node_asg_names" {
  value = "${aws_autoscaling_group.nodes.*.name}"
}

output "spot_node_asg_names" {
  value = "${aws_autoscaling_group.spot_nodes.*.name}"
}