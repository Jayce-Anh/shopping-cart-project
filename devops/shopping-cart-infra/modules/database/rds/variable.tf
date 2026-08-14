############################## VARIABLES ##############################

#========== Project ==========#
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
  description = "Common tags applied to all resources"
}

#============== RDS ==============#
variable "rds_vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "rds_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the RDS subnet group"
}

variable "rds_allowed_sg" {
  type        = list(string)
  description = "List of allowed security group IDs to RDS instance"
}

variable "rds_kms_key" {
  type        = string
  description = "KMS key ARN"
}