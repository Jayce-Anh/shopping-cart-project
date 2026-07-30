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

#================ Parameter Store =================#
variable "source_services" {
  type        = list(string)
  default     = []
  description = "List of services to create parameter store"
}

