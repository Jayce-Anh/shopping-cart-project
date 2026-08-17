############################ VARIABLES ############################

#================ Project =================#
variable "project" {
  type        = map(any)
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#================ Code Pipeline =================#
variable "cicd_git" {
  type = object({
    org    = string
    branch = string
    repos  = map(string)
  })
  description = "GitHub org, shared branch, and per-service repo names (web-ui, auth, product, cart)"
}

#================ Code Build =================#

variable "cicd_ui_env" {
  type        = map(string)
  description = "Environment variables for the web-ui codebuild project"
}

variable "cicd_auth_env" {
  type        = map(string)
  description = "Environment variables for the auth codebuild project"
}

variable "cicd_product_env" {
  type        = map(string)
  description = "Environment variables for the product codebuild project"
}

variable "cicd_cart_env" {
  type        = map(string)
  description = "Environment variables for the cart codebuild project"
}