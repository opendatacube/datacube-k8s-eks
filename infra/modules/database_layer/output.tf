output "db_username" {
  value = "${var.db_username}"
}

output "db_password" {
  value = "${random_string.password.result}"
}

output "db_hostname" {
  value      = "${aws_db_instance.db.address}"
  depends_on = ["aws_db_instance.db"]
}

output "port" {
  depends_on = ["aws_db_instance.db"]
  value      = "${aws_db_instance.db.port}"
}
