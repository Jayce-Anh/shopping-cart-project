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

#================ S3 =================#
variable "sse_algorithm" {
  type        = string
  default     = "aws:kms"
  description = "Server-side encryption algorithm"
}
