output "db_admin_username" {
  value = var.db_admin_username
}

output "db_admin_password" {
  value = random_string.password.result
}

output "db_hostname" {

  value      = aws_db_instance.db.address
  depends_on = [aws_db_instance.db]
}

output "port" {
  value      = aws_db_instance.db.port
  depends_on = [aws_db_instance.db]
}
