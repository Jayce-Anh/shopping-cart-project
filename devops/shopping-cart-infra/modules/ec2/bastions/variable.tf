############################### BASTION VARIABLES ###############################

#================ Project =================#
variable "project" {
  type        = map(string)
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#================ Bastion =================#
variable "vpc_id" {
  type        = string
  description = "VPC ID for the bastion"
}

variable "subnet_id" {
  type        = string
  description = "Public subnet ID for the bastion"
}

variable "kms_key_id" {
  type        = string
  default     = null
  nullable    = true
  description = "KMS key ARN/ID for EBS encryption for the bastion"
}

variable "allowed_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Allowed CIDRs for bastion inbound access"
}
