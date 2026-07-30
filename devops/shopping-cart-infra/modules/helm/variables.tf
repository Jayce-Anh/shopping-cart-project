################################### VARIABLES ###################################

#============== Project ================#
variable "project" {
  type = object({
    name        = string
    env         = string
    region      = string
    account_ids = list(string)
  })
  description = "Project metadata (env, name, region, account_ids)"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#============== EKS ================#
variable "helm_eks_cluster_id" {
  type        = string
  description = "Eks cluster id"
}

variable "helm_vpc_id" {
  type        = string
  description = "Vpc id"
}

variable "argocd_target_group_arn" {
  type        = string
  default     = null
  description = "Terraform external ALB target group ARN for ArgoCD TargetGroupBinding"
}

#================= Helm charts =================#
# Addons configuration
variable "helm_enable_addons" {
  type = object({
    argocd             = optional(bool, false)
    cluster_autoscaler = optional(bool, false)
    ex_secrets         = optional(bool, false)
    karpenter          = optional(bool, false)
  })
  default     = {}
  description = "Define which Helm addons to deploy"
}

variable "enable_kms" {
  type        = bool
  default     = false
  description = "Enable KMS decrypt policy for Secrets Manager secrets (plan-time toggle)"
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "KMS key ARN for Secrets Manager secrets (null = AWS-managed key)"
}

# Cluster Autoscaler
variable "helm_ca_version" {
  type        = string
  default     = null
  nullable    = true
  description = "Cluster Autoscaler Helm chart version (latest when null)"
}

# Karpenter
variable "helm_karpenter_version" {
  type        = string
  default     = null
  nullable    = true
  description = "Karpenter Helm chart version (latest when null)"
}

# Load Balancer Controller
variable "helm_lbc_version" {
  type        = string
  default     = null
  nullable    = true
  description = "AWS Load Balancer Controller Helm chart version (latest when null)"
}

# Cert Manager
variable "helm_cert_manager_version" {
  type        = string
  default     = null
  nullable    = true
  description = "cert-manager Helm chart version (latest when null)"
}

# Argo CD
variable "argocd_version" {
  type        = string
  default     = null
  nullable    = true
  description = "ArgoCD Helm chart version (latest when null)"
}

variable "argocd_cert_arn" {
  type        = string
  default     = null
  description = "Deprecated: ACM cert is attached to external ALB listener"
}

variable "argocd_cert_mode" {
  type    = string
  default = "insecure"
  validation {
    condition     = contains(["insecure", "secure"], var.argocd_cert_mode)
    error_message = "argocd_cert_mode must be insecure or secure."
  }
  description = "ArgoCD TLS mode: insecure (TLS terminated at ALB, HTTP to ArgoCD server) or secure (HTTPS to ArgoCD server via cert-manager)"
}

variable "argocd_cert_issuer_name" {
  type        = string
  default     = "selfsigned-issuer"
  description = "cert-manager ClusterIssuer name for ArgoCD server TLS (secure mode only)"
}

variable "argocd_hostname" {
  type        = string
  description = "Public hostname for ArgoCD UI"
}

variable "argocd_git_token_secret" {
  type        = string
  default     = null
  description = "Secrets Manager secret name for the GitLab fine-grained PAT"
}

variable "argocd_git_repo_url" {
  type        = string
  default     = null
  description = "HTTPS URL of the Git repo ArgoCD watches"
}

variable "argocd_git_target_revision" {
  type        = string
  default     = "main"
  description = "Branch or tag ArgoCD syncs from"
}

variable "argocd_app_path" {
  type        = string
  default     = "./argocd/"
  description = "Path inside the repo where the root Application manifests live"
}

variable "argocd_app_name" {
  type        = string
  default     = "argocd"
  description = "Name of the ArgoCD root Application resource"
}

variable "argocd_git_secret_name" {
  type        = string
  default     = "argocd-repo-creds"
  description = "Name of the Kubernetes secret holding the Git HTTPS credentials"
}

variable "argocd_admin_password" {
  type        = string
  sensitive   = true
  description = "Plaintext ArgoCD admin password (module stores a stable bcrypt hash for Helm)"
}

#============== App Services (Pod Identity) ================#
variable "helm_pod_identity_roles" {
  type = map(object({
    namespace       = string
    service_account = string
    inline_policies = optional(map(object({
      resources = list(string)
    })), {})
    policy_arns = optional(list(string), [])
  }))
  default     = {}
  description = "Pod Identity roles for app service accounts: namespace, service account, inline policies, and optional managed policy ARNs"
}

