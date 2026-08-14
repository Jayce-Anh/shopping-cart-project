######################## ECR OUTPUT ############################
output "ecr_url" {
  description = "Map of ECR repository URLs by service name"
  value       = { for k, r in aws_ecr_repository.ecr : k => r.repository_url }
}

output "ecr_name" {
  description = "Map of ECR repository names by service name"
  value       = { for k, r in aws_ecr_repository.ecr : k => r.name }
}

output "ecr_arn" {
  description = "Map of ECR repository ARNs by service name"
  value       = { for k, r in aws_ecr_repository.ecr : k => r.arn }
}
