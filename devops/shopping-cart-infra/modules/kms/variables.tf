########################### VARIABLES ###########################

#========================= Project =========================#
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

#========================= KMS =========================#
variable "kms_enable_services" {
  type = object({
    rds            = optional(bool, false)
    elasticache    = optional(bool, false)
    ecr            = optional(bool, false)
    sqs            = optional(bool, false)
    secretsmanager = optional(bool, false)
    eks            = optional(bool, false)
    ec2            = optional(bool, false)
  })
  default     = {}
  description = "Per-service KMS toggle — drives per-service key ARN outputs"
}
