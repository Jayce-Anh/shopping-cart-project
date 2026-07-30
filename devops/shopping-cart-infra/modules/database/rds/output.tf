################################ OUTPUTS ################################

output "rds_endpoint" {
  description = "Primary (writer) endpoint host:port"
  value       = aws_db_instance.db.endpoint
}

output "rds_address" {
  description = "Primary (writer) hostname"
  value       = aws_db_instance.db.address
}

output "rds_reader_endpoint" {
  description = "Read replica endpoint host:port (null when read replica is disabled)"
  value       = var.read_replica_enable ? aws_db_instance.read_replica[0].endpoint : null
}

output "rds_reader_address" {
  description = "Read replica hostname (null when read replica is disabled)"
  value       = var.read_replica_enable ? aws_db_instance.read_replica[0].address : null
}

output "db_username" {
  value = aws_db_instance.db.username
}

output "db_port" {
  value = aws_db_instance.db.port
}

output "db_password" {
  description = "RDS master password"
  value       = var.rds_password
  sensitive   = true
}

output "db_instance_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.db.arn
}
