##################### OUTPUTS #####################

output "table_name" {
  description = "Lock table name"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "table_arn" {
  description = "Lock table ARN when enabled, otherwise null"
  value       = aws_dynamodb_table.terraform_locks.arn
}
