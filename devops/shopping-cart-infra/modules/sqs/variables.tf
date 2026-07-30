############################### VARIABLES ###############################

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

#================ SQS =================#
variable "sqs_name" {
  type        = string
  default     = "sqs"
  description = "Suffix for the SQS queue name"
}

variable "sqs_visibility_timeout" {
  type        = number
  default     = 30
  description = "Visibility timeout in seconds"
}

variable "sqs_message_retention_seconds" {
  type        = number
  default     = 345600
  description = "Message retention period in seconds"
}

variable "sqs_fifo_queue" {
  type        = bool
  default     = false
  description = "Create a FIFO queue"
}

variable "sqs_delay_seconds" {
  type        = number
  default     = 0
  description = "Delay before messages become available"
}

variable "sqs_receive_wait_time_seconds" {
  type        = number
  default     = 10
  description = "Long polling wait time in seconds"
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "KMS key ARN for SQS message encryption (null = unencrypted)"
}
