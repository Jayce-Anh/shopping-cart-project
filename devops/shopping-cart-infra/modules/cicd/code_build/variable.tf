############################ VARIABLES ############################

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

variable "env_vars_codebuild" {
  type        = map(string)
  description = "Environment variables for the CodeBuild project"
}

variable "codebuild_role_arn" {
  type        = string
  description = "IAM role ARN for the CodeBuild project"
}

variable "buildspec_file" {
  type        = string
  description = "Buildspec file"
}

variable "build_name" {
  type        = string
  description = "Build name"
}

