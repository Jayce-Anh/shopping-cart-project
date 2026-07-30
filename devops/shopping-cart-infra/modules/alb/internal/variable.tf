######################## VARIABLES ########################

#================ Project =================#
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

#================ VPC =================#

variable "vpc_id" {
  type        = string
  description = "Vpc id"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet ids"
}

variable "dns_cert_arn" {
  type        = string
  description = "Dns cert arn"
}

variable "source_ingress_sg_cidr" {
  type        = list(string)
  description = "Source ingress sg cidr"
}

#================ ALB =================#
variable "lb_name" {
  type        = string
  description = "Lb name"
}

