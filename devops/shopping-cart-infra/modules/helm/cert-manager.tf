####################### CERT-MANAGER #######################

locals {
  helm_install_cert_manager = var.helm_enable_addons.argocd && var.argocd_cert_mode == "secure"
}

resource "helm_release" "cert_manager" {
  count = local.helm_install_cert_manager ? 1 : 0

  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  version          = var.helm_cert_manager_version
  create_namespace = true

  set = [
    {
      name  = "crds.enabled"
      value = "true"
    },
  ]

  timeout = 300
  wait    = true

  depends_on = [helm_release.load_balancer_controller]
}

resource "kubectl_manifest" "cert_manager_cluster_issuer" {
  count    = local.helm_install_cert_manager ? 1 : 0
  provider = kubectl

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${var.argocd_cert_issuer_name}
spec:
  selfSigned: {}
YAML

  depends_on = [helm_release.cert_manager]
}
