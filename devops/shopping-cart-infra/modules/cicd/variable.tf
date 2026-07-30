############################ VARIABLES ############################

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

#================ Code Build =================#
variable "env_vars_codebuild" {
  type        = map(string)
  description = "Environment variables for the codebuild project"
}

variable "buildspec_file" {
  type        = string
  description = "Buildspec file"
}

variable "build_name" {
  type        = string
  description = "Build name"
}

#================ Code Deploy =================#
variable "enable_codedeploy" {
  type        = bool
  default     = false
  description = "Enable Code Deploy"
}

variable "instance_codedeploy" {
  type    = string
  default = null
  validation {
    condition     = !var.enable_codedeploy || (var.instance_codedeploy != null && var.instance_codedeploy != "")
    error_message = "instance_codedeploy must be set when enable_codedeploy is true."
  }
  description = "EC2 instance Name tag for CodeDeploy deployment group (required when enable_codedeploy is true)"
}

variable "appspec_file" {
  type        = string
  default     = null
  description = "Appspec file"
}

variable "appspec_path" {
  type        = string
  default     = null
  description = "Appspec path"
}

variable "env_vars_codedeploy" {
  type        = map(string)
  default     = {}
  description = "Environment variables for the code deploy pipeline"
}

#================ Code Pipeline =================#
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
  default     = true
  description = "Force destroy the S3 bucket"
}

