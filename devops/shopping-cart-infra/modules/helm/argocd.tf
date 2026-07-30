####################### ARGOCD HELM RELEASE #######################

locals {
  argocd_server_insecure  = var.argocd_cert_mode == "insecure"
  argocd_tgb_service_port = local.argocd_server_insecure ? 80 : 443

  argocd_helm_base_sets = [
    {
      name  = "server.service.type"
      value = "ClusterIP"
    },
    {
      name  = "configs.params.server\\.insecure"
      value = tostring(local.argocd_server_insecure)
    },
    {
      name  = "server.ingress.enabled"
      value = "false"
    },
    {
      name  = "configs.cm.url"
      value = "https://${var.argocd_hostname}"
    },
  ]

  argocd_helm_secure_sets = var.argocd_cert_mode == "secure" ? [
    {
      name  = "server.certificate.enabled"
      value = "true"
    },
    {
      name  = "server.certificate.domain"
      value = "${var.argocd_hostname}"
    },
    {
      name  = "server.certificate.issuer.group"
      value = "cert-manager.io"
    },
    {
      name  = "server.certificate.issuer.kind"
      value = "ClusterIssuer"
    },
    {
      name  = "server.certificate.issuer.name"
      value = "${var.argocd_cert_issuer_name}"
    }
  ] : []
}

# Stable bcrypt hash — only changes when plaintext password changes (not every apply)
resource "htpasswd_password" "argocd" {
  count    = var.helm_enable_addons.argocd ? 1 : 0
  password = var.argocd_admin_password
}

resource "time_static" "argocd_admin_password_mtime" {
  count = var.helm_enable_addons.argocd ? 1 : 0
  triggers = {
    hash = htpasswd_password.argocd[0].bcrypt
  }
}

#============ ArgoCD Helm Release =============#
resource "helm_release" "argocd" {
  count = var.helm_enable_addons.argocd ? 1 : 0

  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = var.argocd_version
  create_namespace = true
  timeout          = 300
  wait             = true

  set = concat(
    local.argocd_helm_base_sets,
    local.argocd_helm_secure_sets,
    [
      {
        name  = "configs.secret.argocdServerAdminPasswordMtime"
        value = time_static.argocd_admin_password_mtime[0].rfc3339
      },
    ],
  )

  set_sensitive = [
    {
      name  = "configs.secret.argocdServerAdminPassword"
      value = htpasswd_password.argocd[0].bcrypt
    },
  ]

  depends_on = [
    helm_release.load_balancer_controller,
    aws_iam_role.argocd,
    aws_eks_pod_identity_association.argocd,
    helm_release.cert_manager,
    kubectl_manifest.cert_manager_cluster_issuer,
  ]
}

#============ ArgoCD Target Group Binding =============#
resource "kubectl_manifest" "argocd_tgb" {
  count    = var.helm_enable_addons.argocd ? 1 : 0
  provider = kubectl

  yaml_body = yamlencode({
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind       = "TargetGroupBinding"
    metadata = {
      name      = "argocd-tgb"
      namespace = "argocd"
    }
    spec = {
      serviceRef = {
        name = "argocd-server"
        port = local.argocd_tgb_service_port
      }
      targetGroupARN = var.argocd_target_group_arn
      targetType     = "ip"
    }
  })

  depends_on = [helm_release.argocd]
}

#============ ArgoCD Git HTTPS Credentials Secret =============#
data "aws_secretsmanager_secret" "git_token" {
  count = var.helm_enable_addons.argocd && var.argocd_git_token_secret != null ? 1 : 0
  name  = var.argocd_git_token_secret
}

data "aws_secretsmanager_secret_version" "git_token" {
  count     = var.helm_enable_addons.argocd && var.argocd_git_token_secret != null ? 1 : 0
  secret_id = one(data.aws_secretsmanager_secret.git_token).id
}

resource "kubernetes_secret_v1" "argocd_repo" {
  count = var.helm_enable_addons.argocd && var.argocd_git_token_secret != null ? 1 : 0

  metadata {
    name      = var.argocd_git_secret_name
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = "git"
    url      = var.argocd_git_repo_url
    username = "oauth2"
    password = one(data.aws_secretsmanager_secret_version.git_token).secret_string
  }

  depends_on = [helm_release.argocd]
}

#============ ArgoCD Root Application =============#
resource "kubectl_manifest" "argocd_root_application" {
  count    = var.helm_enable_addons.argocd ? 1 : 0
  provider = kubectl

  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: '${var.argocd_app_name}'
  namespace: argocd
  # Cascade-delete child apps/resources when this Application is destroyed
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: '${var.argocd_git_repo_url}'
    targetRevision: '${var.argocd_git_target_revision}'
    path: '${var.argocd_app_path}'
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
YAML

  depends_on = [
    helm_release.argocd,
    kubernetes_secret_v1.argocd_repo,
  ]
}
