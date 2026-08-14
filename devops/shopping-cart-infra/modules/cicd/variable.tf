############################ VARIABLES ############################

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
variable "git_config" {
  type = object({
    token = optional(string, null),
    org = string
    repo = string
    branch = optional(string, null)
  })
  description = "Git configuration"
}