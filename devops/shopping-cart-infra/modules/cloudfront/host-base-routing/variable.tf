########################### VARIABLES ###########################

#============== Project  ===============#
variable "project" {
  type = object({
    name = string
    env  = string
  })
  description = "Project metadata (env, name, region, account_ids)"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}
