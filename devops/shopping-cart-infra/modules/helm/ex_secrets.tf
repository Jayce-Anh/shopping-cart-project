########################### EXTERNAL SECRETS HELM RELEASE ###########################

resource "helm_release" "external_secrets" {
  count = var.helm_enable_addons.ex_secrets ? 1 : 0

  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "kube-system"
  create_namespace = false
  force_update     = true
  skip_crds        = false
  timeout          = 300
  wait             = true
  wait_for_jobs    = true

  set = [
    {
      name  = "installCRDs"
      value = "true"
    }
  ]

  depends_on = [
    helm_release.load_balancer_controller,
    aws_eks_pod_identity_association.external_secrets,
  ]
}
