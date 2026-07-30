################################ VARIABLES ################################

#============ Project ============#
variable "project" {
  type = object({
    name        = string
    env         = string
    region      = string
    account_ids = list(string)
  })
  description = "Project information"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the WAF"
}

#============ WAF ============#
variable "fe_white_list" {
  type        = list(string)
  description = "Fe white list"
}
