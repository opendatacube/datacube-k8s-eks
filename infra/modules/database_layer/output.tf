output "db_admin_username" {
  value = var.db_admin_username
}

output "db_admin_password" {
  value = random_string.password.result
}

output "db_hostname" {
  value      = var.db_instance_enabled ? aws_db_instance.db[0].address : ""
  depends_on = [aws_db_instance.db]
}

output "port" {
  value      = var.db_instance_enabled ? aws_db_instance.db[0].port : ""
  depends_on = [aws_db_instance.db]
}
