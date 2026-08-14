############################### GITLAB RUNNER VARIABLES ###############################

variable "project" {
  type = object({
    name       = string
    env        = string
    region     = string
    account_id = string
  })
  description = "Project metadata"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the GitLab runner"
}

variable "subnet_id" {
  type        = string
  description = "Public subnet ID for the GitLab runner"
}

variable "runner_kms_key" {
  type        = string
  description = "KMS key ARN/ID for EBS encryption (null = AWS-managed default key) for the GitLab runner"
}
