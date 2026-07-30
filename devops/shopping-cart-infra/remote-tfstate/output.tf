##################### OUTPUTS #####################

#============= S3 backend state ==============#
output "bucket_name" {
  description = "S3 state bucket name"
  value       = module.backend.bucket_name
}

output "bucket_arn" {
  description = "S3 state bucket ARN"
  value       = module.backend.bucket_arn
}

#============= DynamoDB state lock ==============#
# output "dynamodb_table_name" {
#   description = "DynamoDB table name"
#   value       = module.state_lock.table_name
# }
