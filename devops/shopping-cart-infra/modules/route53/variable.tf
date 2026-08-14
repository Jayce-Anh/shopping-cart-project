############################# ROUTE53 VARIABLE ##############################

#=============== Project ================#
variable "project" {
  type = object({
    name   = string
    env    = string
    region = string
  })
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the hosted zone"
}

#=============== Route53 ================#
variable "r53_domain_name" {
  type        = string
  description = "The domain name for the hosted zone"
}
