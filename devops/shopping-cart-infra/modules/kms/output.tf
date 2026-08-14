################################ KMS OUTPUT ################################

output "key_arn" {
  description = "KMS key ARN"
  value       = aws_kms_key.kms.arn
}

output "key_alias" {
  description = "KMS key alias"
  value       = aws_kms_alias.kms.name
}
