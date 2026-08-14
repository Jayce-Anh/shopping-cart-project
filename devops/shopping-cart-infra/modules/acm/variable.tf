############################# ACM VARIABLE ##############################

#=============== Project ================#
variable "project" {
  type = object({
    name       = string
    env        = string
    region     = string
    account_id = string
    domain     = string
  })
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the ACM certificates"
}
