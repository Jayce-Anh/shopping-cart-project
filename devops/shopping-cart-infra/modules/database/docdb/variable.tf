########################### VARIABLES ###########################

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
  type        = map(string)
  description = "Common tags applied to all resources"
}

#================ VPC =================#
variable "network" {
  type = object({
    vpc_id             = string
    private_subnet_ids = list(string)
    public_subnet_ids  = list(string)
  })
  description = "Network"
}

#================ DocumentDB =================#
variable "docdb_name" {
  type        = string
  description = "Name of the DocumentDB cluster"
}

variable "docdb_family" {
  type        = string
  description = "The DB parameter group family"
}

variable "docdb_engine_version" {
  type        = string
  description = "DocumentDB engine version"
}

variable "docdb_username" {
  type        = string
  description = "Master username for the DocumentDB cluster"
}

variable "docdb_password" {
  type        = string
  sensitive   = true
  description = "Master password for the DocumentDB cluster"
}

variable "docdb_port" {
  type        = number
  description = "Port on which the DocumentDB accepts connections"
}

variable "instance_count" {
  type        = number
  description = "Number of DocumentDB instances to create"
}

variable "instance_class" {
  type        = string
  description = "Instance class for DocumentDB instances"
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "The days to retain backups for"
}

variable "preferred_backup_window" {
  type        = string
  description = "The daily time range during which automated backups are performed"
}

variable "preferred_maintenance_window" {
  type        = string
  description = "The weekly time range during which system maintenance can occur"
}

variable "storage_encrypted" {
  type        = bool
  default     = true
  description = "Specifies whether the DocumentDB cluster is encrypted"
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "The ARN for the KMS encryption key"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = true
  description = "Determines whether a final DocumentDB snapshot is created before the cluster is deleted"
}

variable "deletion_protection" {
  type        = bool
  default     = false
  description = "A value that indicates whether the DocumentDB cluster has deletion protection enabled"
}

variable "apply_immediately" {
  type        = bool
  default     = false
  description = "Specifies whether any cluster modifications are applied immediately"
}

variable "docdb_parameters" {
  type        = map(string)
  default     = {}
  description = "A map of DocumentDB parameters to apply"
}

variable "ca_cert_identifier" {
  type        = string
  default     = "rds-ca-2019"
  description = "The identifier of the CA certificate for the DB instance"
}

variable "allowed_sg_ids_access_docdb" {
  type        = list(string)
  default     = []
  description = "List of security group IDs to allow access to the DocumentDB cluster"
}