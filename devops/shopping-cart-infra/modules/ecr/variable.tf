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

#================ ECR =================#
variable "kms_key_id" {
  type        = string
  description = "KMS key ARN for ECR image encryption"
}
