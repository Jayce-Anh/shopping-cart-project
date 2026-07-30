######################### OUTPUTS #########################

output "runner_role_arn" {
  value       = aws_iam_role.ci_runner.arn
  description = "ARN of the CI runner IAM role"
}

output "runner_role_name" {
  value       = aws_iam_role.ci_runner.name
  description = "Name of the CI runner IAM role"
}

output "oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.ci_runner.arn
  description = "ARN of the CI/CD OIDC provider"
}

output "cicd_provider" {
  value       = var.cicd_provider
  description = "Active CI/CD provider (gitlab or github)"
}
