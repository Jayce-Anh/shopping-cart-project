############################ VARIABLES ################################

variable "project" {
  type = object({
    name = string
    env  = string
  })
  description = "Project name and environment"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to CI runner IAM resources"
}

variable "cicd_provider" {
  type    = string
  default = "gitlab"
  validation {
    condition     = contains(["gitlab", "github"], var.cicd_provider)
    error_message = "cicd_provider must be gitlab or github."
  }
  description = "CI/CD provider for OIDC federation: gitlab or github"
}

variable "runner_project_path" {
  type        = string
  description = "GitLab project path (group/project) or GitHub repo (org/repo) for OIDC subject claim"
}

variable "runner_ec2_role_arn" {
  type        = string
  description = "EC2 runner role ARN allowed to assume this role"
}

variable "runner_project_scope" {
  type        = string
  default     = "/*"
  description = "GitHub repo scope (optional, for self-hosted runners)"
}