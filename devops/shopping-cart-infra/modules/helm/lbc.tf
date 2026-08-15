########################### AWS LOAD BALANCER CONTROLLER HELM RELEASE ###########################

resource "helm_release" "load_balancer_controller" {
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  namespace        = "kube-system"
  create_namespace = false

  set = [
    {
      name  = "clusterName"
      value = "${var.helm_eks_cluster}"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "vpcId"
      value = "${var.helm_vpc_id}"
    },
    {
      name  = "region"
      value = "${var.project.region}"
    }
  ]

  timeout = 300
  wait    = true

  depends_on = [
    terraform_data.eks_nodes,
    aws_iam_role_policy_attachment.alb_controller,
    aws_eks_pod_identity_association.alb_controller,
  ]
}
