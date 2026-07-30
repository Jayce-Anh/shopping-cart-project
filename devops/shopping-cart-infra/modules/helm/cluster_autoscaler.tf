############################ CLUSTER AUTOSCALER HELM RELEASE ############################

resource "helm_release" "cluster_autoscaler" {
  count = var.helm_enable_addons.cluster_autoscaler ? 1 : 0

  name             = "cluster-autoscaler"
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  namespace        = "kube-system"
  create_namespace = false
  version          = var.helm_ca_version

  set = [
    {
      name  = "autoDiscovery.clusterName"
      value = var.helm_eks_cluster_id
    },
    {
      name  = "awsRegion"
      value = "${var.project.region}"
    },
    {
      name  = "rbac.serviceAccount.name"
      value = "cluster-autoscaler"
    },
    {
      name  = "extraArgs.balance-similar-node-groups"
      value = "true"
    },
    {
      name  = "extraArgs.skip-nodes-with-local-storage"
      value = "false"
    },
    {
      name  = "extraArgs.skip-nodes-with-system-pods"
      value = "false"
    }
  ]

  timeout = 300

  depends_on = [
    aws_iam_role.cluster_autoscaler,
    aws_eks_pod_identity_association.cluster_autoscaler,
  ]
}
