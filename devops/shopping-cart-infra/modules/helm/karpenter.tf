########################### KARPENTER HELM RELEASE ###########################

resource "helm_release" "karpenter" {
  count = var.helm_enable_addons.karpenter ? 1 : 0

  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  namespace        = "karpenter"
  create_namespace = true
  version          = var.helm_karpenter_version

  set = [
    {
      name  = "settings.clusterName"
      value = var.helm_eks_cluster_id
    },
    {
      name  = "settings.interruptionQueue"
      value = var.helm_eks_cluster_id
    },
    {
      name  = "controller.resources.requests.cpu"
      value = "1"
    },
    {
      name  = "controller.resources.requests.memory"
      value = "1Gi"
    },
    {
      name  = "controller.resources.limits.cpu"
      value = "1"
    },
    {
      name  = "controller.resources.limits.memory"
      value = "1Gi"
    }
  ]

  timeout = 300

  depends_on = [
    aws_iam_role.karpenter,
    aws_eks_pod_identity_association.karpenter,
  ]
}
