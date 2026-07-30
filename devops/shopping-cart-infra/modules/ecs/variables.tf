########################### VARIABLES ###########################

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

#================ ALB =================#

variable "ecs_cluster_name" {
  type        = string
  description = "Name of the ECS cluster"
}

variable "lb_sg_id" {
  type        = string
  description = "Load balancer security group id"
}

variable "target_group_arn" {
  type        = string
  description = "Target group ARN"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "network_mode" {
  type        = string
  default     = "awsvpc"
  description = "Network mode"
}

variable "subnets" {
  type        = list(string)
  description = "Subnets for ECS service"
}

#================ ECS =================#
variable "containerInsights" {
  type        = string
  default     = "disabled"
  description = "Container insights"
}

variable "task_definitions" {
  type = map(object({
    launch_type          = string
    container_name       = string
    container_image      = string
    desired_count        = number
    cpu                  = number
    memory               = number
    container_port       = number
    host_port            = number
    health_check_path    = string
    enable_load_balancer = bool
    load_balancer = optional(object({
      target_group_port = number
      container_port    = number
    }))
  }))
  description = "Task definitions"
}

variable "log_retention" {
  type        = number
  default     = 14
  description = "Log retention"
}
