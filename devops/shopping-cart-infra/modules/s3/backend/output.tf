##################### OUTPUTS #####################

output "bucket_name" {
  description = "S3 state bucke name"
  value       = aws_s3_bucket.backend_state.id
}

output "bucket_arn" {
  description = "S3 state bucket ARN"
  value       = aws_s3_bucket.backend_state.arn
}
