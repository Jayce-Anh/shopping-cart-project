######################## VARIABLES ########################

#================ Project =================#
variable "project" {
  type = object({
    name   = string
    env    = string
    domain = string
  })
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#================ VPC =================#
variable "alb_vpc_id" {
  type        = string
  description = "VPC ID for the ALB"
}

variable "alb_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for the ALB"
}

#================ DNS =================#
variable "alb_dns_cert" {
  type        = string
  description = "ACM certificate ARN for the HTTPS listener"
}
