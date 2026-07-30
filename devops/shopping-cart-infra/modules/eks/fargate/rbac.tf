##################################### FARGATE RBAC #########################################
#----------- Provider -----------
# Still needed for kubernetes_service_account in fargate_profile.tf
provider "kubernetes" {
  host                   = aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks.name]
  }
}

#----------- Cluster Auth -----------
data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.eks.name
}

# Fargate execution role access entry 
resource "aws_eks_access_entry" "fargate" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = aws_iam_role.eks_fargate.arn
  type          = "FARGATE_LINUX"

  depends_on = [
    aws_eks_cluster.eks
  ]
}

# Additional access entries for custom roles
resource "aws_eks_access_entry" "additional_roles" {
  for_each = { for idx, role in var.map_roles : idx => role }

  cluster_name      = aws_eks_cluster.eks.name
  principal_arn     = each.value.rolearn
  kubernetes_groups = each.value.groups
  type              = "STANDARD"

  depends_on = [
    aws_eks_cluster.eks
  ]
}