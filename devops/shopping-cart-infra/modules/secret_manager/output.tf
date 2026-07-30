############################### SECRET MANAGER - OUTPUT ###############################

output "secret_names" {
  description = "Map of secret names"
  value       = { for k, v in aws_secretsmanager_secret.secret : k => v.name }
}

output "secret_arns" {
  description = "Map of secret ARNs"
  value       = { for k, v in aws_secretsmanager_secret.secret : k => v.arn }
}

output "secret_ids" {
  description = "Map of secret IDs"
  value       = { for k, v in aws_secretsmanager_secret.secret : k => v.id }
}

