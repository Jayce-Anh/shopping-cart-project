######################## GITLAB RUNNER OUTPUT ###########################

output "sg_id" {
  value = aws_security_group.runner.id
}

output "instance_id" {
  value = aws_instance.runner.id
}

output "public_ip" {
  value = aws_eip.runner.public_ip
}

output "private_ip" {
  value = aws_instance.runner.private_ip
}

output "role_arn" {
  value       = aws_iam_role.runner.arn
  description = "ARN of the GitLab runner EC2 IAM role"
}

output "instance_arn" {
  value       = aws_instance.runner.arn
  description = "ARN of the GitLab runner instance"
}

output "ci_provider_role_arn" {
  value       = aws_iam_role.ci_provider.arn
  description = "ARN of the GitLab CI provider IAM role (OIDC + EC2 assume)"
}

output "ci_provider_role_name" {
  value       = aws_iam_role.ci_provider.name
  description = "Name of the GitLab CI provider IAM role"
}

output "oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.gitlab.arn
  description = "ARN of the GitLab OIDC provider"
}
