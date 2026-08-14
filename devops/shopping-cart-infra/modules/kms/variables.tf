########################### KMS VARIABLE  ###########################

#========================= Project =========================#
variable "project" {
  type = object({
    name   = string
    env    = string
    region = string
    account_id = string
  })
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}
