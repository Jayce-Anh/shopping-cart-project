################################ OUTPUTS ################################

output "key_arn" {
  description = "KMS key ARN (raw — use per-service outputs instead)"
  value       = aws_kms_key.main.arn
}

output "key_alias" {
  description = "KMS key alias"
  value       = aws_kms_alias.main.name
}

#============ Per-service ARNs — null when service toggle is false ============#
output "ecr_key_arn" {
  description = "KMS key ARN for ECR (null = AES256)"
  value       = var.kms_enable_services.ecr ? aws_kms_key.main.arn : null
}

output "rds_key_arn" {
  description = "KMS key ARN for RDS (null = unencrypted)"
  value       = var.kms_enable_services.rds ? aws_kms_key.main.arn : null
}

output "elasticache_key_arn" {
  description = "KMS key ARN for ElastiCache (null = unencrypted)"
  value       = var.kms_enable_services.elasticache ? aws_kms_key.main.arn : null
}

output "sqs_key_arn" {
  description = "KMS key ARN for SQS (null = unencrypted)"
  value       = var.kms_enable_services.sqs ? aws_kms_key.main.arn : null
}

output "secretsmanager_key_arn" {
  description = "KMS key ARN for Secrets Manager (null = AWS-managed key)"
  value       = var.kms_enable_services.secretsmanager ? aws_kms_key.main.arn : null
}

output "eks_key_arn" {
  description = "KMS key ARN for EKS secrets + EBS volumes (null = unencrypted)"
  value       = var.kms_enable_services.eks ? aws_kms_key.main.arn : null
}

output "ec2_key_arn" {
  description = "KMS key ARN for EC2 EBS volumes (null = unencrypted)"
  value       = var.kms_enable_services.ec2 ? aws_kms_key.main.arn : null
}
