############################### VARIABLES ###############################

#================ Project =================#
variable "project" {
  type = object({
    name        = string
    env         = string
    region      = string
  })
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#================ SQS =================#
variable "sqs_name" {
  type        = string
  default     = "sqs"
  description = "Suffix for the SQS queue name"
}

variable "sqs_kms_key" {
  type        = string
  description = "KMS key ARN for SQS message encryption"
}
