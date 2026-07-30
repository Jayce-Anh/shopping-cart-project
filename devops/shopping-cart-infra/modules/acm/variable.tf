##################### VARIABLES #####################

#=========== Project ==========#
variable "project" {
  type = object({
    env         = string
    name        = string
    region      = string
    account_ids = list(string)
  })
  description = "Project metadata (env, name, region, account_ids)"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#=========== ACM ==========#
variable "acm_region" {
  type        = string
  description = "AWS region where ACM certificates are created"
}

variable "acm_certs" {
  type = map(object({
    domain                    = string
    subject_alternative_names = optional(list(string), null)
  }))
  description = "ACM certificates keyed by use case (alb, cf, ...)"
}
