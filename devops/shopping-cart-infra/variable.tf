############################## VARIABLE VALUES ##############################

#=============== Project ================#
variable "project" {
  type = object({
    name       = string
    env        = string
    region     = string
    account_id = string
    domain     = string
    admin_user = string
  })
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

variable "helm_repo" {
  type        = string
  description = "Helm repository URL"
}
