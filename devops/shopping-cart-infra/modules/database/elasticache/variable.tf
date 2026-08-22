########################### ELASTICACHE VARIABLES ###########################

#============ Project ============#
variable "project" {
  type        = map(string)
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#================= Cache ===================#
variable "cache_vpc_id" {
  type        = string
  description = "VPC ID where cache security group will be created"
}

variable "cache_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the cache subnet group"
}

variable "cache_allowed_sg" {
  type        = list(string)
  description = "List of security group IDs allowed to access the cache"
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "KMS key ARN for ElastiCache at-rest encryption"
}
