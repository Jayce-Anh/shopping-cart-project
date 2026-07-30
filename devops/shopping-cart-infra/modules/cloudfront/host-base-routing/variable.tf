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

#============== CloudFront ===============#
variable "cf_service_name" {
  type        = string
  default     = "fe"
  description = "Name of the service for CloudFront"
}

variable "cf_versioning" {
  type        = any
  default     = {}
  description = "Map containing versioning configuration."
}

variable "cf_ownership_config" {
  type        = any
  default     = null
  description = "Map containing bucket ownership configuration."
}

variable "cf_custom_error_response" {
  type        = any
  default     = {}
  description = "One or more custom error response elements"
}

variable "cf_cert_arn" {
  type        = string
  description = "Cert arn"
}

variable "cf_cert_domain" {
  type        = string
  description = "Domain name of the SSL certificate"
}

variable "cf_create_full_access_policy" {
  type        = bool
  default     = true
  description = "whether or not to create iam policy of s3 full access"
}

variable "cf_s3_force_del" {
  type        = bool
  default     = false
  description = "Force destroy the S3 bucket"
}
