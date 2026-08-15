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

#================ Hosted Zone =================#
variable "acm_hosted_zone_id" {
  type        = string
  description = "Hosted zone ID for the ACM certificate"
}