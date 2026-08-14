#################################### RBAC ####################################

#=============== Admin Access Entry ===============#
# EKS cluster access 
resource "aws_eks_access_entry" "admin" {
  for_each = var.eks_admin_access

  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = each.value
  type          = "STANDARD"

  depends_on = [aws_eks_cluster.eks]
}

resource "aws_eks_access_policy_association" "admin" {
  for_each = var.eks_admin_access

  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = each.value
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin]
}
