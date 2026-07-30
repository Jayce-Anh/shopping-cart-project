#################################### EKS CLUSTER ####################################

locals {
  # eks_name == project.name: cluster stays project.name, labels use "eks".
  use_project_cluster_name = var.eks_name == var.project.name
  eks_cluster_name         = local.use_project_cluster_name ? var.project.name : var.eks_name
  eks_label                = local.use_project_cluster_name ? "eks" : var.eks_name
}

#================ EKS Cluster =================#
resource "aws_eks_cluster" "eks" {
  name     = local.eks_cluster_name
  version  = var.eks_version
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    subnet_ids              = var.eks_subnet
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.endpoint_public_access ? var.endpoint_public_access_cidrs : null
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  # Enable self-managed addons - these are essential for nodes to join the cluster
  bootstrap_self_managed_addons = true

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  dynamic "encryption_config" {
    for_each = var.enable_kms ? [1] : []
    content {
      resources = ["secrets"]
      provider {
        key_arn = var.kms_key_arn
      }
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster,
    aws_iam_role_policy_attachment.eks_vpc,
  ]

  # Increase timeout for cluster deletion to allow node groups time to fully terminate
  timeouts {
    delete = "10m"
  }

  lifecycle {
    create_before_destroy = false
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${local.eks_label}-cluster"
  })
}






