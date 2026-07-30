#------------------ ALB Controller Service Account ------------------
resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
  }

  depends_on = [
    aws_eks_fargate_profile.eks_fargate,
    aws_iam_role_policy_attachment.alb_controller,
  ]
}

#------------------ Fargate Profile ------------------
resource "aws_eks_fargate_profile" "eks_fargate" {
  for_each = var.fargates

  cluster_name           = aws_eks_cluster.eks.name
  fargate_profile_name   = each.key
  pod_execution_role_arn = aws_iam_role.eks_fargate.arn
  subnet_ids             = lookup(each.value, "subnet_ids")

  selector {
    namespace = "default"
  }

  # Wait for essential add-ons before creating Fargate profiles
  depends_on = [
    aws_eks_addon.vpc_cni,
    aws_eks_addon.kube_proxy
  ]

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-eks-fargate-profile-${each.key}"
  })
}

