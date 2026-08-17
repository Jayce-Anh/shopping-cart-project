###################### ECS VARIABLE ######################

#============== Project ================#
variable "project" {
  type        = map(any)
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#=============== ECS ================#
variable "ecs_lb_sg_id" {
  description = "Load balancer security group id"
  type        = string
}

variable "ecs_target_group_arns" {
  type        = map(string)
  description = "Target group ARNs keyed by service name (auth, product, cart)"
}

variable "ecs_vpc_id" {
  type        = string
  description = "VPC ID for ECS service"
}

variable "ecs_subnets" {
  type        = list(string)
  description = "Subnets for ECS service"
}