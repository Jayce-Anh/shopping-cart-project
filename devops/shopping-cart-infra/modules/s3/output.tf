########################## S3 REMOTE STATE OUTPUT ##########################

#=============== Remote State S3 ================#
output "remote_state_bucket_id" {
  value = aws_s3_bucket.remote_state.id
}

output "remote_state_bucket_arn" {
  value = aws_s3_bucket.remote_state.arn
}
