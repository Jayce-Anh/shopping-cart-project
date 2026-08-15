####################### S3 REMOTE STATE VARIABLE ##########################

variable "project" {
  type = object({
    name       = string
    env        = string
    region     = string
    account_id = string
  })
}

variable "tags" {
  type = map(string)
}