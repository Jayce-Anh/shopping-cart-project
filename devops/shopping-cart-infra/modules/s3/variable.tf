################################ S3 REMOTE STATE VARIABLE ############################

#=============== Project ================#
variable "project" {
  type = object({
    name   = string
    env    = string
    region = string
  })
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the S3 bucket"
}