############################ VARIABLES ############################

variable "codedeploy_role_arn" {
  type        = string
  description = "IAM role ARN for the CodeDeploy application"
}

variable "instance_codedeploy" {
  type        = string
  description = "EC2 instance Name tag for the CodeDeploy deployment group"
}

variable "project" {
  type = object({
    region      = string
    name        = string
    env         = string
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

variable "appspec_file" {
  type        = string
  description = "Appspec file"
}

variable "appspec_path" {
  type        = string
  description = "Appspec path"
}

variable "env_vars_codedeploy" {
  type        = map(string)
  description = "Env vars codedeploy"
}
