####################### CERT-MANAGER #######################

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "kube-system"
  create_namespace = false

  set = [
    {
      name  = "crds.enabled"
      value = "true"
    },
  ]

  timeout = 300
  wait    = true

  depends_on = [
    terraform_data.eks_nodes,
    helm_release.load_balancer_controller,
  ]
}

resource "kubernetes_manifest" "cert_manager_cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "selfsigned-issuer"
    }
    spec = {
      selfSigned = {}
    }
  }

  depends_on = [helm_release.cert_manager]
}
