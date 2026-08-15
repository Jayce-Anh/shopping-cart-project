################################### VARIABLES ###################################

variable "project" {
  type = object({
    name       = string
    env        = string
    region     = string
    account_id = string
    domain     = string
  })
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#=============== Helm =================#

variable "helm_eks_cluster" {
  type        = string
  description = "EKS cluster name"
}

variable "helm_eks_node_group_id" {
  type        = string
  description = "EKS node group ID. Implicit destroy-order lock so nodes stay until Helm/K8s resources are gone."
}

variable "helm_vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "helm_kms_key" {
  type        = string
  description = "KMS key ARN for Secrets Manager decrypt policies"
}

variable "helm_repo_url" {
  type        = string
  description = "Helm repository URL"
}

variable "helm_target_revision" {
  type        = string
  default     = "main"
  description = "ArgoCD target revision (Helm repository branch)"
}

variable "helm_argocd_tg_arn" {
  type        = string
  description = "External ALB ArgoCD target group ARN for TargetGroupBinding"
}

variable "helm_sqs_queue_arn" {
  type        = string
  description = "SQS queue ARN for inventory/order pod identity access"
}

variable "helm_rds_secret_arn" {
  type        = string
  description = "ARN of the RDS credentials secret for External Secrets"
}