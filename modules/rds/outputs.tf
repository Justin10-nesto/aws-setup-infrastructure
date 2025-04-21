output "db_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = var.create_rds_instance ? aws_db_instance.todo_db[0].endpoint : null
}

output "db_address" {
  description = "Address of the RDS instance"
  value       = var.create_rds_instance ? aws_db_instance.todo_db[0].address : null
}

output "db_name" {
  description = "Name of the database"
  value       = var.db_name
}

output "db_username" {
  description = "Username for the database"
  value       = var.db_username
}

output "db_password" {
  description = "Password for the database"
  value       = var.db_password
  sensitive   = true
}

output "db_port" {
  description = "Port for the database connection"
  value       = var.db_port
}

output "db_connection_string" {
  description = "Full connection string for the database"
  value       = var.create_rds_instance ? "mysql://${var.db_username}:${var.db_password}@${aws_db_instance.todo_db[0].endpoint}/${var.db_name}" : null
  sensitive   = true
}

output "is_rds_available" {
  description = "Whether RDS instance is available"
  value       = var.create_rds_instance
}