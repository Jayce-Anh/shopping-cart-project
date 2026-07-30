############################ VARIABLES ############################

variable "git_token" {
  type        = string
  description = "Git token for the code pipeline"
}

variable "git_org" {
  type        = string
  description = "Git organization for the code pipeline"
}

variable "git_repo" {
  type        = string
  description = "Git repository for the code pipeline"
}

variable "git_branch" {
  type        = string
  description = "Git branch for the code pipeline"
}

variable "pipeline_name" {
  type        = string
  description = "Name of the code pipeline"
}

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
  type = object({
    Name = string
  })
  description = "Common tags applied to all resources"
}

variable "project_name" {
  type        = string
  description = "The name of the code build project"
}

# variable "application_name" {
#   description = "The name of the code deploy application"
#   type = string
# }

# variable "deployment_group_name" {
#   description = "The name of the code deploy deployment group"
#   type = string
# }

variable "enable_ecs_deploy" {
  type        = bool
  default     = false
  description = "Enable ECS deployment stage"
}

variable "ecs_cluster_name" {
  type        = string
  default     = null
  description = "Name of the ECS cluster"
}

variable "ecs_service_name" {
  type        = string
  default     = null
  description = "Name of the ECS service"
}

variable "s3_force_del" {
  type        = bool
  description = "Force destroy the S3 bucket"
}

