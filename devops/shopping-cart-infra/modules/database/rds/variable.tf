############################## VARIABLES ##############################

#========== Project ==========#
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

#============== RDS ==============#
variable "rds_name" {
  type        = string
  description = "Name of the RDS instance (alphanumeric only)"
}

variable "multi_az" {
  type        = bool
  default     = false
  description = "If set to true, RDS instance is multi-AZ"
}

variable "rds_class" {
  type        = string
  default     = "db.t4g.small"
  description = "Instance class for the RDS instance"
}

variable "rds_storage" {
  type        = number
  default     = 30
  description = "Allocated storage size in GB for the RDS instance"
}

variable "rds_max_storage" {
  type        = number
  default     = 100
  description = "Maximum allocated storage in GB for autoscaling"
}

variable "rds_storage_type" {
  type        = string
  default     = "gp3"
  description = "Storage type for the RDS instance (e.g. gp2, gp3, io1)"
}

variable "rds_iops" {
  type        = number
  default     = 3000
  description = "Provisioned IOPS for the RDS storage (used with gp3 or io1)"
}

variable "rds_throughput" {
  type        = number
  default     = 125
  description = "Storage throughput in MiB/s for gp3 storage type"
}

variable "rds_family" {
  type        = string
  description = "Parameter group family for the RDS instance (e.g. mysql8.0, postgres15)"
}

variable "rds_engine" {
  type        = string
  description = "Database engine for the RDS instance (e.g. mysql, postgres)"
}

variable "rds_engine_version" {
  type        = string
  description = "Version of the database engine"
}

variable "rds_port" {
  type        = string
  description = "Port on which the RDS instance accepts connections"
}

variable "rds_username" {
  type        = string
  description = "Master username for the RDS instance"
}

variable "rds_password" {
  type        = string
  sensitive   = true
  description = "Master password for the RDS instance"
}

variable "rds_backup_retention_period" {
  type        = number
  default     = 7
  description = "Number of days to retain automated backups (0 disables backups)"
}

variable "rds_performance_insights_retention_period" {
  type        = number
  default     = 0
  description = "Retention period in days for Performance Insights data (0 disables it)"
}

variable "rds_aws_db_parameters" {
  type        = map(string)
  description = "Custom parameters for RDS instance"
}

variable "rds_allowed_sg_ids_access" {
  type        = list(string)
  description = "List of security group IDs allowed to access the RDS instance"
}

variable "rds_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the RDS subnet group"
}

variable "rds_vpc_id" {
  type        = string
  description = "Vpc id"
}

variable "rds_backup_window" {
  type        = string
  default     = "00:30-01:30"
  description = "Daily UTC time window for automated backups (e.g. 00:30-01:30)"
}

variable "rds_maintenance_window" {
  type        = string
  default     = "sat:04:30-sat:05:30"
  description = "Weekly UTC time window for RDS maintenance (e.g. sat:04:30-sat:05:30)"
}

#============== Read Replica ==============#
variable "read_replica_enable" {
  type        = bool
  default     = false
  description = "Create a read replica and expose a reader endpoint"
}

variable "read_replica_class" {
  type        = string
  default     = null
  nullable    = true
  description = "Instance class for the read replica (defaults to primary class)"
}

variable "read_replica_skip_final_snapshot" {
  type        = bool
  default     = true
  description = "Skip final snapshot when the RDS instance is deleted"
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "KMS key ARN for RDS storage encryption (null = AWS managed key)"
}

#========== Scheduler ==========#
variable "rds_scheduler" {
  type = object({
    cron_start = optional(string, "cron(0 9 ? * MON-FRI *)")
    cron_stop  = optional(string, "cron(0 18 ? * MON-FRI *)")
    timezone   = optional(string, "Asia/Singapore")
  })
  default     = null
  nullable    = true
  description = "Scheduler settings for RDS stop/start (null = disabled)"
}