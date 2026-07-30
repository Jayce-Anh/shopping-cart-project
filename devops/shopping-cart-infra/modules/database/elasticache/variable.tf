########################### VARIABLES ###########################

#============ Project ============#
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

#================= Cache ===================#s
variable "cache_name" {
  type        = string
  default     = "valkey"
  description = "Name of the cache instance"
}

variable "cache_port" {
  type        = number
  default     = 6379
  description = "Port of the cache instance"
}

variable "cache_engine" {
  type        = string
  default     = "valkey"
  description = "Engine of the cache instance"
}

variable "allowed_sg_ids_access_cache" {
  type        = list(string)
  default     = []
  description = "List of security group IDs allowed to access cache"
}

variable "allowed_cidr_blocks_access_cache" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks allowed to access cache"
}

variable "cache_parameters" {
  type        = map(string)
  default     = {}
  description = "Custom parameters for cache instance"
}

variable "cache_version" {
  type        = string
  description = "Engine version of the cache instance (e.g. 7.2)"
}

variable "cache_family" {
  type        = string
  default     = "valkey7"
  description = "Parameter group family (e.g. valkey7, redis7.x, etc.)"
}

variable "cache_node_type" {
  type        = string
  default     = "cache.t4g.small"
  description = "Node type of the cache instance"
}

variable "cache_num_cache_clusters" {
  type        = number
  default     = 1
  description = "Number of cache clusters (nodes) in the replication group"
}

variable "cache_snapshot_retention_limit" {
  type        = number
  default     = 1
  description = "Number of days to retain automatic snapshots"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the cache subnet group"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where cache security group will be created"
}

variable "snapshot_window" {
  type        = string
  default     = "00:30-01:30"
  description = "Daily time range for snapshots (UTC)"
}

variable "maintenance_window" {
  type        = string
  default     = "sat:04:30-sat:05:30"
  description = "Weekly time range for maintenance"
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "KMS key ARN for ElastiCache at-rest encryption (null = AWS managed key)"
}
