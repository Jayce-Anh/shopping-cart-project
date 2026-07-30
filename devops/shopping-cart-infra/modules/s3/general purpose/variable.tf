##################### VARIABLES #####################
variable "project" {
  type = object({
    name        = string
    env         = string
    region      = string
    account_ids = list(number)
  })
  description = "Project metadata (env, name, region, account_ids)"
}

variable "tags" {
  type = object({
    Name = string
  })
  description = "Common tags applied to all resources"
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "versioning" {
  type = object({
    status     = string
    mfa_delete = string
  })
  default = {
    status     = "Enabled"
    mfa_delete = null
  }
  description = "Versioning configuration"
}

variable "sse_algorithm" {
  type        = string
  default     = "AES256"
  description = "Server-side encryption algorithm"
}

variable "block_public_acls" {
  type        = bool
  default     = true
  description = "Block public ACLs"
}

variable "block_public_policy" {
  type        = bool
  default     = true
  description = "Block public policy"
}

variable "ignore_public_acls" {
  type        = bool
  default     = true
  description = "Ignore public ACLs"
}

variable "restrict_public_buckets" {
  type        = bool
  default     = true
  description = "Restrict public buckets"
}