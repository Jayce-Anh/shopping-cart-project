######################################## ADDONS ########################################

#==================== Get addons versions =====================#
data "aws_eks_addon_version" "addons" {
  for_each           = toset(["vpc-cni", "coredns", "kube-proxy", "eks-pod-identity-agent", "aws-ebs-csi-driver"])
  addon_name         = each.value
  kubernetes_version = aws_eks_cluster.eks.version
  most_recent        = true
}

#==================== Addons =====================#
resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "vpc-cni"
  addon_version = data.aws_eks_addon_version.addons["vpc-cni"].version
  configuration_values = jsonencode({
    env = {
      ENABLE_PREFIX_DELEGATION = "true"
      WARM_PREFIX_TARGET       = "1"
    }
  })

  depends_on = [aws_eks_cluster.eks]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "kube-proxy"
  addon_version = data.aws_eks_addon_version.addons["kube-proxy"].version

  depends_on = [aws_eks_cluster.eks]
}

resource "aws_eks_addon" "coredns" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "coredns"
  addon_version = data.aws_eks_addon_version.addons["coredns"].version

  depends_on = [
    aws_eks_addon.vpc_cni,
    aws_eks_node_group.node_group,
  ]
}

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = data.aws_eks_addon_version.addons["eks-pod-identity-agent"].version

  depends_on = [aws_eks_node_group.node_group]
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = data.aws_eks_addon_version.addons["aws-ebs-csi-driver"].version

  depends_on = [
    aws_eks_cluster.eks,
    aws_eks_addon.pod_identity_agent,
    aws_eks_pod_identity_association.ebs_csi,
    aws_eks_node_group.node_group,
  ]
}

#==================== Pod Identity Association =====================#
resource "aws_eks_pod_identity_association" "ebs_csi" {
  cluster_name    = aws_eks_cluster.eks.name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs_csi_driver.arn

  depends_on = [aws_eks_addon.pod_identity_agent]
}
