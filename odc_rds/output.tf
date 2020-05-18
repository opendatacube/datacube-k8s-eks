output "db_admin_username" {
  value     = var.db_admin_username
  sensitive = true
}

output "db_admin_password" {
  value     = random_string.password.result
  sensitive = true
}

output "db_hostname" {
  value = aws_db_instance.db.address
}

output "db_port" {
  value = aws_db_instance.db.port
}
