############################### SECRET MANAGER - VARIABLE ###############################

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

#================ Secret Manager =================#
variable "secrets" {
  type = map(object({
    secret_name             = string
    use_initial_value       = optional(bool, true)
    secret_data             = optional(map(string), {})
    secret_string           = optional(string, null)
    recovery_window_in_days = optional(number, 30)
    description             = optional(string, null)
  }))
  validation {
    condition = alltrue([
      for _, v in var.secrets :
      v.secret_string == null || length(v.secret_data) == 0
    ])
    error_message = "Use either secret_string (plain text) or secret_data (JSON map)"
  }
  description = "Create secret manager with managed value"
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "KMS key ARN to encrypt secrets (null = AWS managed key)"
}
