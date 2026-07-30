##################### OUTPUTS #####################

output "bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.backend_state.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.backend_state.arn
}

