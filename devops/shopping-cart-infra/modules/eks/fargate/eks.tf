######################## EKS FARGATE ########################
#------------------ EKS Cluster ------------------
resource "aws_eks_cluster" "eks" {
  name     = var.eks_name
  version  = var.eks_version
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    subnet_ids = var.eks_subnet
    # Let EKS auto-create the cluster security group - don't override it
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.endpoint_public_access ? var.endpoint_public_access_cidrs : null
  }

  # Enable self-managed addons - essential for Fargate workloads
  bootstrap_self_managed_addons = true

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster,
    aws_iam_role_policy_attachment.eks_vpc,
  ]

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-eks-cluster"
  })
}

