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
  description = "Read replica endpoint host:port"
  value       = aws_db_instance.read_replica.endpoint
}

output "rds_reader_address" {
  description = "Read replica hostname"
  value       = aws_db_instance.read_replica.address
}

output "rds_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.db.arn
}

output "rds_credentials" {
  description = "RDS credentials"
  value       = {
    DATABASE_USERNAME = "${aws_db_instance.db.username}"
    DATABASE_PASSWORD = "${random_password.rds.result}"
    DATABASE_HOST     = "${aws_db_instance.db.address}"
    DATABASE_PORT     = "${aws_db_instance.db.port}"
  }
}
