####################### VARIABLES #######################

#=========== Project Configuration ==========#
variable "project" {
  type = object({
    name       = string
    env        = string
    region     = string
    account_id = string
  })
  description = "Project metadata configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#================== EKS =====================#
variable "eks_vpc_id" {
  type        = string
  description = "VPC ID for EKS cluster"
}

variable "eks_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for EKS cluster and node group"
}

variable "eks_kms_key" {
  type        = string
  description = "KMS key ARN for EKS secrets envelope encryption and EBS volume encryption"
}

variable "eks_allowed_sg" {
  type        = list(string)
  default     = []
  description = "Security group IDs allowed to reach the EKS cluster API (e.g. bastion, GitLab runner)"
}

variable "eks_alb_sg_id" {
  type        = string
  description = "External ALB security group ID allowed to reach service pods on nodes"
}

variable "eks_admin_access" {
  type        = map(string)
  default     = {}
  description = "Allows IAM user/role to authenticate to the EKS cluster"
}
