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

#================ Instance =================#
variable "asg_ami_id" {
  type        = string
  default     = null
  description = "AMI ID (if null, uses Ubuntu 22.04 LTS)"
}

variable "asg_instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Instance type for ASG"
}

variable "asg_iops" {
  type        = number
  default     = 3000
  description = "IOPS for the EBS volume"
}

variable "asg_volume_type" {
  type    = string
  default = "gp3"
  validation {
    condition     = contains(["gp3", "gp2", "io1", "io2", "io2e", "io1e", "st1", "sc1"], var.asg_volume_type)
    error_message = "Volume type must be one of: gp3, gp2, io1, io2, io2e, io1e, st1, sc1"
  }
  description = "Type of the EBS volume"
}

variable "asg_volume_size" {
  type        = number
  default     = 40
  description = "Volume size"
}

variable "asg_instance_name" {
  type        = string
  description = "Name prefix for ASG resources"
}

variable "asg_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for ASG instances across multiple AZs"
}

variable "asg_vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "asg_path_user_data" {
  type        = string
  default     = null
  description = "Path to user data script"
}

variable "asg_key_name" {
  type        = string
  description = "Name of the existing AWS key pair"
}

variable "asg_kms_key_arn" {
  type        = string
  default     = null
  description = "KMS key ARN for EBS volume encryption (null = unencrypted)"
}

variable "asg_sg_ingress" {
  type = map(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    description              = string
    source_security_group_id = optional(string, null)
    cidr_blocks              = optional(list(string), ["0.0.0.0/0"])
  }))
  description = "Map of ingress rules for security group"
}

variable "asg_sg_egress" {
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
  description = "Map of egress rules for security group"
}

#========== IAM Access Control ==========#
variable "asg_enable_iam_access" {
  type = object({
    ssm            = optional(bool, true)
    ecr            = optional(bool, true)
    secretsmanager = optional(bool, false)
    s3             = optional(bool, false)
    eks            = optional(bool, false)
    ecs            = optional(bool, false)
  })
  default     = {}
  description = "Define which AWS service access to grant to the instance IAM role"
}

#========== Auto Scaling Group ==========#
variable "asg_desired_capacity" {
  type        = number
  default     = 1
  description = "Desired number of instances in ASG"
}

variable "asg_max_size" {
  type        = number
  default     = 3
  description = "Maximum number of instances in ASG"
}

variable "asg_min_size" {
  type        = number
  default     = 1
  description = "Minimum number of instances in ASG"
}

variable "asg_force_del" {
  type        = bool
  default     = false
  description = "Force delete the Auto Scaling Group"
}

variable "asg_health_check_type" {
  type    = string
  default = "EC2"
  validation {
    condition     = contains(["EC2", "ELB"], var.asg_health_check_type)
    error_message = "Health check type must be either EC2 or ELB"
  }
  description = "Health check type for ASG (EC2 or ELB)"
}

variable "asg_health_check_grace_period" {
  type        = number
  default     = 300
  description = "Time (in seconds) after instance launch before health checks start"
}

variable "asg_termination_policies" {
  type        = list(string)
  default     = ["Default"]
  description = "List of policies to use for instance termination"
}

variable "asg_target_group_arns" {
  type        = list(string)
  default     = null
  description = "List of target group ARNs to attach to ASG (for ALB integration)"
}

variable "asg_wait_for_capacity_timeout" {
  type        = string
  default     = "10m"
  description = "Maximum time to wait for desired capacity to be reached"
}

#======================== Scheduler =========================#
variable "asg_scheduler_up" {
  type = object({
    min       = optional(number, 1)
    max       = optional(number, 3)
    desired   = optional(number, 1)
    cron      = optional(string, "0 9 * * MON-FRI")
    time_zone = optional(string, "UTC")
  })
  default     = null
  nullable    = true
  description = "Cron to scale ASG up (null = disabled)"
}

variable "asg_scheduler_down" {
  type = object({
    min       = optional(number, 0)
    max       = optional(number, 0)
    desired   = optional(number, 0)
    cron      = optional(string, "0 18 * * MON-FRI")
    time_zone = optional(string, "UTC")
  })
  default     = null
  nullable    = true
  description = "Cron to scale ASG down (null = disabled)"
}
