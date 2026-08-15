############################ EKS OUTPUT ############################

output "eks_cluster_id" {
  value = aws_eks_cluster.eks.id
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.eks.arn
}

output "node_group_id" {
  value       = aws_eks_node_group.node_group.id
  description = "EKS node group ID. Passed to Helm so nodes are not destroyed before Helm/K8s resources."
}

output "node_group_sg_id" {
  value       = aws_security_group.node_group.id
  description = "EKS node group security group ID"
}

output "cluster_security_group_id" {
  value       = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
  description = "EKS cluster security group ID"
}
