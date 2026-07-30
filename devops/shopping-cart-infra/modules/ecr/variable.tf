############################ VARIABLES ############################

#================ Project =================#
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

#============== ECR ===============#
variable "ecr_services" {
  type = map(object({
    name             = string
    keep_nums_images = optional(number, 10)
    force_del        = optional(bool, false)
  }))
  description = "Map of ECR services to per-repo settings"
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "KMS key ARN for ECR image encryption (null = AES256)"
}