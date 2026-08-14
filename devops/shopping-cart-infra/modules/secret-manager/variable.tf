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

variable "secret_kms_key" {
  type        = string
  description = "KMS key ARN to encrypt secrets"
}
