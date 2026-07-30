########################### VARIABLES ###########################

#================ Project =================#
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

#============== Cloudfront ===============#
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
  description = "ARN of the SSL certificate to use for the CloudFront distribution"
}

variable "cf_aliases" {
  type        = list(string)
  description = "Alternate domain names (CNAMEs) for the CloudFront distribution"
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

#============== API Backend ===============#
variable "cf_alb_dns_name" {
  type        = string
  default     = null
  description = "DNS name of the ALB. Set to use ALB as /api/* origin."
}

variable "cf_api_gw_domain" {
  type        = string
  default     = null
  description = "API Gateway domain (hostname only, no https://). Set to use API GW as /api/* origin."
}

variable "cf_api_gw_origin_path" {
  type        = string
  default     = "/prod"
  description = "API Gateway origin path used as CloudFront origin_path (e.g. /prod, /v1)."
}
