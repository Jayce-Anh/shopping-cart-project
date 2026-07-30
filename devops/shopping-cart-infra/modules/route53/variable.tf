########################### VARIABLES ###########################

#========== Project ==========#
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

#================ Route53 =================#
variable "route53_domain_name" {
  type        = string
  description = "Root domain name for the public hosted zone"
}

variable "route53_comment" {
  type        = string
  default     = null
  description = "Comment for the hosted zone"
}

variable "route53_hosted_zone_force_del" {
  type        = bool
  default     = false
  description = "Whether to destroy all records in the zone when deleting the hosted zone"
}

variable "route53_acm_certificates" {
  type = map(list(object({
    domain_name           = string
    resource_record_name  = string
    resource_record_type  = string
    resource_record_value = string
  })))
  default     = {}
  description = "ACM domain validation options keyed by certificate name (e.g. regional, cloudfront)"
}
