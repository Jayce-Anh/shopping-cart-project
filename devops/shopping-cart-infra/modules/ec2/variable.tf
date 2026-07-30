############################### VARIABLES ###############################

#================ Project =================#
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

#================ EC2 instance =================#
variable "ec2_ami_id" {
  type        = string
  default     = null
  description = "AMI ID for EC2 instance (if null, uses Ubuntu 22.04 LTS)"
}

variable "ec2_instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Instance type for single EC2"
}

variable "ec2_capacity_type" {
  type    = string
  default = "ON_DEMAND"
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.ec2_capacity_type)
    error_message = "ec2_capacity_type must be ON_DEMAND or SPOT"
  }
  description = "Purchase option: ON_DEMAND or SPOT"
}

variable "ec2_spot_max_price" {
  type        = string
  default     = null
  description = "Maximum spot price per hour (null uses on-demand price as cap)"
}

variable "ec2_spot_instance_interruption_behavior" {
  type    = string
  default = "terminate"
  validation {
    condition     = contains(["terminate", "stop"], var.ec2_spot_instance_interruption_behavior)
    error_message = "ec2_spot_instance_interruption_behavior must be terminate or stop"
  }
  description = "Behavior when a spot instance is interrupted: terminate or stop"
}

variable "ec2_kms_key_arn" {
  type        = string
  default     = null
  description = "KMS key ARN for EBS volume encryption (null = unencrypted)"
}

variable "ec2_iops" {
  type        = number
  default     = 3000
  description = "IOPS for the EC2 instance"
}

variable "ec2_volume_size" {
  type        = number
  default     = 40
  description = "Volume size"
}

variable "ec2_volume_type" {
  type    = string
  default = "gp3"
  validation {
    condition     = contains(["gp3", "gp2", "io1", "io2", "io2e", "io1e", "st1", "sc1"], var.ec2_volume_type)
    error_message = "ec2_volume_type must be one of: gp3, gp2, io1, io2, io2e, io1e, st1, sc1"
  }
  description = "Type of the EBS volume"
}

variable "ec2_enabled_eip" {
  type        = bool
  default     = true
  description = "Attach Elastic IP to single EC2 instance"
}

variable "ec2_instance_name" {
  type        = string
  description = "Name of the EC2 instance"
}

variable "ec2_delete_on_termination" {
  type        = bool
  default     = true
  description = "Delete the EBS volume on termination"
}

variable "ec2_subnet_id" {
  type        = string
  default     = null
  nullable    = true
  description = "Subnet ID for single EC2 instance"
}

variable "ec2_vpc_id" {
  type        = string
  description = "VPC ID where the EC2 instance will be created"
}

variable "ec2_alb_sg_id" {
  type        = string
  default     = ""
  description = "Security group ID of ALB (optional)"
}

variable "ec2_path_user_data" {
  type        = string
  default     = null
  description = "Path to user data script"
}

variable "ec2_key_name" {
  type        = string
  description = "Name of the existing AWS key pair"
}

variable "ec2_sg_ingress" {
  type = map(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    description              = string
    source_security_group_id = optional(string, null)
    cidr_blocks              = optional(list(string), ["0.0.0.0/0"])
  }))
  description = "Map of ingress rules for EC2 security group"
}

variable "ec2_sg_egress" {
  type = map(object({
    from_port                = optional(number, 0)
    to_port                  = optional(number, 0)
    protocol                 = optional(string, "-1")
    description              = optional(string, "Allow outbound access")
    cidr_blocks              = optional(list(string), ["0.0.0.0/0"])
    source_security_group_id = optional(string, null)
  }))
  default = {
    all = {
      description = "Allow all outbound"
    }
  }
  description = "Map of egress rules for EC2 security group"
}

#========== IAM Access Control ==========#
variable "ec2_enable_iam_access" {
  type = object({
    ssm            = optional(bool, true)
    ecr            = optional(bool, true)
    secretsmanager = optional(bool, false)
    s3             = optional(bool, false)
    eks            = optional(bool, false)
    ecs            = optional(bool, false)
  })
  default     = {}
  description = "Define which AWS service access to grant to the EC2 instance IAM role"
}

#========== Scheduler ==========#
variable "ec2_scheduler" {
  type = object({
    cron_start = optional(string, "cron(0 9 ? * MON-FRI *)")
    cron_stop  = optional(string, "cron(0 18 ? * MON-FRI *)")
    timezone   = optional(string, "Asia/Singapore")
  })
  default     = null
  nullable    = true
  description = "Scheduler settings for EC2 stop/start (null = disabled)"
}

