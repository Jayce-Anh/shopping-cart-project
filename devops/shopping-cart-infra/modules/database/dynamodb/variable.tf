########################### VARIABLES ###########################

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

#================ DynamoDB =================#
variable "table_name" {
  type        = string
  default     = "tf-state-locks"
  description = "Name of the lock table"
}

variable "billing_mode" {
  type        = string
  default     = "PAY_PER_REQUEST"
  description = "Billing mode of the lock table"
}

variable "hash_key" {
  type        = string
  default     = "LockID"
  description = "Hash key of the lock table"
}

variable "hash_key_type" {
  type        = string
  default     = "S"
  description = "Type of the hash key"
}