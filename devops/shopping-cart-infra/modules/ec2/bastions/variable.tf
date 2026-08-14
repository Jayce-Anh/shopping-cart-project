############################### BASTION VARIABLES ###############################

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
  description = "VPC ID for the bastion"
}

variable "subnet_id" {
  type        = string
  description = "Public subnet ID for the bastion"
}

variable "bastion_kms_key" {
  type        = string
  default     = null
  nullable    = true
  description = "KMS key ARN/ID for EBS encryption (null = AWS-managed default key) for the bastion"
}
