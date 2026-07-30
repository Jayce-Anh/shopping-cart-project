######################################## ADDONS ########################################

#==================== Get addons versions =====================#
data "aws_eks_addon_version" "vpc_cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = aws_eks_cluster.eks.version
  most_recent        = true
}
data "aws_eks_addon_version" "coredns" {
  addon_name         = "coredns"
  kubernetes_version = aws_eks_cluster.eks.version
  most_recent        = true
}
data "aws_eks_addon_version" "kube_proxy" {
  addon_name         = "kube-proxy"
  kubernetes_version = aws_eks_cluster.eks.version
  most_recent        = true
}
data "aws_eks_addon_version" "ebs_csi_driver" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.eks.version
  most_recent        = true
}
data "aws_eks_addon_version" "pod_identity_agent" {
  addon_name         = "eks-pod-identity-agent"
  kubernetes_version = aws_eks_cluster.eks.version
  most_recent        = true
}

#==================== Addons =====================#
resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "vpc-cni"
  addon_version = data.aws_eks_addon_version.vpc_cni.version
  configuration_values = jsonencode({
    env = {
      ENABLE_PREFIX_DELEGATION = "true"
      WARM_PREFIX_TARGET       = "1"
    }
  })

  depends_on = [
    aws_eks_cluster.eks
  ]
}

resource "aws_eks_addon" "coredns" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "coredns"
  addon_version = data.aws_eks_addon_version.coredns.version

  # CoreDNS needs healthy nodes to run
  depends_on = [
    aws_eks_addon.vpc_cni,
    aws_eks_node_group.node_groups
  ]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "kube-proxy"
  addon_version = data.aws_eks_addon_version.kube_proxy.version

  depends_on = [
    aws_eks_cluster.eks
  ]
}

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = data.aws_eks_addon_version.pod_identity_agent.version

  depends_on = [
    aws_eks_node_group.node_groups,
  ]
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = data.aws_eks_addon_version.ebs_csi_driver.version

  depends_on = [
    aws_eks_cluster.eks,
    aws_eks_addon.pod_identity_agent,
    aws_eks_pod_identity_association.ebs_csi,
    aws_eks_node_group.node_groups,
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

#Command to get version: aws eks describe-addon-versions --addon-name <addon-name> --kubernetes-version <eks-version>
#Example: aws eks describe-addon-versions --addon-name vpc-cni --kubernetes-version 1.31
