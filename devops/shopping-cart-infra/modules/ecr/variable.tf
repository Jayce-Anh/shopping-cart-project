############################ ECR VARIABLE ############################

#================ Project =================#
variable "project" {
  type = object({
    name = string
    env  = string
  })
  description = "Project metadata (env, name)"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

variable "ecr_kms_key" {
  type        = string
  description = "KMS key ARN for ECR image encryption"
}
