########################### VARIABLES ###########################

#================ Project =================#
variable "project" {
  type = object({
    name   = string
    env    = string
    region = string
    domain = string
  })
  description = "Project configuration"
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

variable "cf_hosted_zone_id" {
  type        = string
  description = "Hosted zone ID for the CloudFront certificate"
}