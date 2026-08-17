############################### SECRET MANAGER VARIABLE ###############################

#================ Project =================#
variable "project" {
  type = object({
    name = string
    env  = string
  })
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#================ Secret ==================#
variable "secret_kms_key" {
  type        = string
  description = "KMS key ARN to encrypt secrets"
}

variable "secret_rds" {
  type = object({
    DATABASE_USERNAME = string
    DATABASE_PASSWORD = string
    DATABASE_HOST     = string
    DATABASE_PORT     = string
  })
  sensitive   = true
  description = "RDS credentials"
}
