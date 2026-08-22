############################### GITLAB RUNNER VARIABLES ###############################

#================ Project =================#
variable "project" {
  type        = map(string)
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#================ GitLab Runner =================#
variable "vpc_id" {
  type        = string
  description = "VPC ID for the GitLab runner"
}

variable "subnet_id" {
  type        = string
  description = "Public subnet ID for the GitLab runner"
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ARN/ID for EBS encryption for the GitLab runner"
}

variable "allowed_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Allowed CIDRs for GitLab runner inbound access"
}
