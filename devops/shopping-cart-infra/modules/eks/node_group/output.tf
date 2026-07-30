############################ OUTPUT ############################

# EKS cluster id
output "eks_cluster_id" {
  value = aws_eks_cluster.eks.id
}

# EKS cluster name
output "eks_cluster_name" {
  value = aws_eks_cluster.eks.name
}

# EKS cluster endpoint
output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

# EKS cluster ARN
output "eks_cluster_arn" {
  value = aws_eks_cluster.eks.arn
}

output "node_group_sg_ids" {
  description = "Security group IDs for EKS node groups"
  value       = values({ for k, v in aws_security_group.node_groups : k => v.id })
}

output "node_group_sg_id" {
  description = "Map of node group key to security group ID"
  value       = { for k, v in aws_security_group.node_groups : k => v.id }
}

output "node_group_sg_map" {
  description = "Map of node group name to security group ID"
  value       = { for k, v in aws_security_group.node_groups : k => v.id }
}

output "public_alb_sg_id" {
  description = "Security group ID for shared EKS public ALB (ArgoCD, Grafana, Kibana, ...)"
  value       = local.public_alb_sg_id
}

# IRSA (OIDC) outputs — disabled, replaced by EKS Pod Identity
# output "oidc_provider_arn" {
#   description = "ARN of the EKS OIDC provider (used for IRSA)"
#   value       = aws_iam_openid_connect_provider.eks.arn
# }
#
# output "oidc_url" {
#   description = "OIDC issuer URL without https:// prefix (used in IAM trust conditions)"
#   value       = trimprefix(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://")
# }