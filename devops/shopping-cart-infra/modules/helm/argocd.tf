####################### ARGOCD HELM RELEASE #######################

#================= Password =================#
# Always get the latest version of the secret credentials
data "aws_secretsmanager_secret_version" "helm_addon" {
  secret_id = var.helm_addon_secret
}

# Password of argocd admin user
resource "htpasswd_password" "argocd" {
  password = jsondecode(data.aws_secretsmanager_secret_version.helm_addon.secret_string).argocd_password
}

#================= Time =================#
resource "time_static" "argocd_admin_password_mtime" {
  triggers = {
    hash = htpasswd_password.argocd.bcrypt
  }
}

#================= Helm Release =================#
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  timeout          = 300
  wait             = true

  set = [
    {
      name  = "server.service.type"
      value = "ClusterIP"
    },
    {
      name  = "configs.params.server\\.insecure"
      value = "false"
    },
    {
      name  = "server.ingress.enabled"
      value = "false"
    },
    {
      name  = "configs.cm.url"
      value = "https://argocd.${var.project.env}-${var.project.name}.${var.project.domain}"
    },
    {
      name  = "server.certificate.enabled"
      value = "true"
    },
    {
      name  = "server.certificate.domain"
      value = "argocd.${var.project.env}-${var.project.name}.${var.project.domain}"
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
      value = "selfsigned-issuer"
    },
    {
      name  = "configs.secret.argocdServerAdminPasswordMtime"
      value = time_static.argocd_admin_password_mtime.rfc3339
    },
  ]

  set_sensitive = [
    {
      name  = "configs.secret.argocdServerAdminPassword"
      value = htpasswd_password.argocd.bcrypt
    },
  ]

  depends_on = [
    terraform_data.eks_nodes,
    helm_release.load_balancer_controller,
    helm_release.cert_manager,
    kubernetes_manifest.cert_manager_cluster_issuer,
    aws_iam_role.argocd,
    aws_eks_pod_identity_association.argocd,
  ]
}

#================= Secret =================#
# Always get the latest version of the secret credentials
data "aws_secretsmanager_secret_version" "helm_git_token" {
  secret_id = var.helm_git_token_secret
}

# Git token for argocd repo synchronization
resource "kubernetes_secret_v1" "argocd_repo" {
  metadata {
    name      = "argocd-repo-creds"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = "git"
    url      = var.helm_repo_url
    username = "oauth2"
    password = data.aws_secretsmanager_secret_version.helm_git_token.secret_string
  }

  depends_on = [helm_release.argocd]
}

#============ ArgoCD Target Group Binding =============#
resource "kubernetes_manifest" "argocd_tgb" {
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind       = "TargetGroupBinding"
    metadata = {
      name      = "argocd-tgb"
      namespace = "argocd"
    }
    spec = {
      serviceRef = {
        name = "argocd-server"
        port = 443
      }
      targetGroupARN = "${var.helm_argocd_tg_arn}"
      targetType     = "ip"
    }
  }

  timeouts {
    delete = "5m"
  }

  depends_on = [
    helm_release.argocd,
    helm_release.load_balancer_controller,
  ]
}

resource "kubernetes_manifest" "argocd_root_application" {
  manifest = yamldecode(<<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argocd
  namespace: argocd
spec:
  project: default
  source:
    repoURL: '${var.helm_repo_url}'
    targetRevision: '${var.helm_target_revision}'
    path: 'argocd/'
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
YAML
  )

  depends_on = [
    helm_release.argocd,
    kubernetes_secret_v1.argocd_repo,
  ]
}
