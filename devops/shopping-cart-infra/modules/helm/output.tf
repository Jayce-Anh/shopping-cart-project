################################### OUTPUTS ###################################

output "argocd_role_arn" {
  description = "IAM role ARN for ArgoCD"
  value       = aws_iam_role.argocd.arn
}

output "lbc_role_arn" {
  description = "IAM role ARN for Load Balancer Controller"
  value       = aws_iam_role.alb_controller.arn
}

output "ca_role_arn" {
  description = "IAM role ARN for Cluster Autoscaler"
  value       = aws_iam_role.cluster_autoscaler.arn
}

output "karpenter_role_arn" {
  description = "IAM role ARN for Karpenter"
  value       = aws_iam_role.karpenter.arn
}
