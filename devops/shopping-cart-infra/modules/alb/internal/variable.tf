######################## VARIABLES ########################

#================ Project =================#
variable "project" {
  type = object({
    name        = string
    env         = string
    region      = string
    account_id  = string
  })
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#================ VPC =================#

variable "vpc_id" {
  type        = string
  description = "Vpc id"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet ids"
}

variable "alb_dns_cert" {
  type        = string
  description = "ALB DNS certificate ARN"
}

variable "source_ingress_sg_cidr" {
  type        = list(string)
  description = "Source ingress security group CIDR"
}