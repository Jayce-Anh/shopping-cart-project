#################################### EKS CLUSTER ####################################

#================ EKS Cluster =================#
resource "aws_eks_cluster" "eks" {
  name     = var.project.name
  version  = "1.35"
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    subnet_ids              = var.eks_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  bootstrap_self_managed_addons = true
  enabled_cluster_log_types     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = var.eks_kms_key
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster,
    aws_iam_role_policy_attachment.eks_vpc,
    aws_iam_role_policy.eks_cluster_kms,
  ]

  timeouts {
    delete = "10m"
  }

  lifecycle {
    create_before_destroy = false
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-eks-cluster"
  })
}
