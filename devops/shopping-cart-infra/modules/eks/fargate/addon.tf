######################################## ADDONS ########################################
#------- Get addons versions -------
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

# ------- EKS ADDONS -------
resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "vpc-cni"
  addon_version = data.aws_eks_addon_version.vpc_cni.version

  # Don't depend on Fargate profiles - they need this addon to function
  depends_on = [
    aws_eks_cluster.eks
  ]
}

resource "aws_eks_addon" "coredns" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "coredns"
  addon_version = data.aws_eks_addon_version.coredns.version

  # CoreDNS can depend on VPC CNI but not on Fargate profiles
  depends_on = [
    aws_eks_addon.vpc_cni
  ]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "kube-proxy"
  addon_version = data.aws_eks_addon_version.kube_proxy.version

  # Don't depend on Fargate profiles - they need this addon to function
  depends_on = [
    aws_eks_cluster.eks
  ]
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = data.aws_eks_addon_version.ebs_csi_driver.version
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  # EBS CSI can be installed after cluster creation and OIDC provider
  depends_on = [
    aws_eks_cluster.eks,
    aws_iam_openid_connect_provider.eks
  ]

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.eks_name}-ebs-csi-driver"
  })
}

#-------- Extra addons -------
resource "aws_eks_addon" "eks_addons_extra" {
  for_each = { for v in var.addons : v.name => v }

  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = each.value.name
  addon_version            = each.value.version
  service_account_role_arn = lookup(each.value, "role_arn", null)

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-eks-addon-${each.value.name}"
  })
}

#Command to get version: aws eks describe-addon-versions --addon-name <addon-name> --kubernetes-version <eks-version>
#Example: aws eks describe-addon-versions --addon-name vpc-cni --kubernetes-version 1.31
