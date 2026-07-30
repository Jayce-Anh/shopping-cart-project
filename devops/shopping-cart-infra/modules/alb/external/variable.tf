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

variable "alb_vpc_id" {
  type        = string
  description = "Vpc id"
}

variable "alb_subnet_ids" {
  type        = list(string)
  description = "Subnet ids"
}

#================ DNS =================#

variable "alb_dns_cert" {
  type        = string
  default     = null
  description = "ARN of the DNS certificate"
}

#================ ALB =================#

variable "alb_enable_https_listener" {
  type        = bool
  default     = false
  description = "Enable HTTPS listener (requires alb_dns_cert)"
}

variable "alb_source_ingress_sg_cidr" {
  type        = list(string)
  description = "Source ingress security group CIDR"
}

variable "alb_name" {
  type        = string
  description = "Name"
}

#================ Target Group =================#
variable "alb_target_groups" {
  type = map(object({
    name                  = string
    service_port          = number
    health_check_path     = string
    priority              = number
    path_patterns         = optional(list(string), null) # used when behind CloudFront (path-based routing)
    host_header           = optional(string, null)       # used for direct domain-based routing
    protocol              = optional(string, "HTTP")
    health_check_protocol = optional(string, null)
    target_type           = optional(string, "ip") # "ip" for containerized services, "instance" for EC2 instances
    ec2_id                = optional(string, null) # EC2 instance ID if use EC2 instances
  }))
  default     = {}
  description = "Map of target groups to create"
}

