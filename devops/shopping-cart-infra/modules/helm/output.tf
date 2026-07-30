################################### OUTPUTS ###################################

output "argocd_role_arn" {
  description = "IAM role ARN for ArgoCD"
  value       = var.helm_enable_addons.argocd ? aws_iam_role.argocd[0].arn : null
}

output "lbc_role_arn" {
  description = "IAM role ARN for Load Balancer Controller"
  value       = aws_iam_role.alb_controller.arn
}

output "ca_role_arn" {
  description = "IAM role ARN for Cluster Autoscaler"
  value       = var.helm_enable_addons.cluster_autoscaler ? aws_iam_role.cluster_autoscaler[0].arn : null
}
