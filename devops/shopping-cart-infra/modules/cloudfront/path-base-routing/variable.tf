########################### VARIABLES ###########################

#================ Project =================#
variable "project" {
  type = object({
    name = string
    env  = string
    domain = string
  })
  description = "Project metadata (env, name, region, account_ids)"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#============== Cloudfront ===============#
variable "cf_alb_dns_name" {
  type        = string
  description = "DNS name of the ALB used as /api/* origin"
}
