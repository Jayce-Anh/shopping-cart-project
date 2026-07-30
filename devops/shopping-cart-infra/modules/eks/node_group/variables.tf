####################### VARIABLES #######################

#=========== Project Configuration ==========#
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

#================== EKS =====================#
variable "eks_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "eks_version" {
  type        = string
  description = "Version of the EKS cluster"
}

variable "eks_vpc" {
  type        = string
  description = "VPC ID"
}

variable "eks_subnet" {
  type        = list(string)
  description = "Subnet IDs"
}

#========== Node Groups ==========#
variable "node_groups" {
  type = map(object({
    subnet_ids      = optional(list(string))
    min_size        = number
    max_size        = number
    desired_size    = number
    instance_types  = optional(list(string))
    capacity_type   = optional(string) # "ON_DEMAND" or "SPOT"
    disk_size       = optional(number, 30)
    disk_type       = optional(string, "gp3")
    ami_type        = optional(string, "AL2023_x86_64_STANDARD")
    release_version = optional(string)
    key_name        = optional(string)
    labels          = optional(map(string))
    ingress_rules = optional(map(object({
      from_port                = number
      to_port                  = number
      protocol                 = string
      cidr_blocks              = optional(list(string))
      source_security_group_id = optional(string)
      self                     = optional(bool)
      description              = optional(string)
    })), {})
    egress_rules = optional(map(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string))
      description = optional(string)
      })), {
      all_outbound = {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "All outbound traffic"
      }
    })
    tags             = optional(map(string))
    enable_scheduler = optional(bool, false)
    cron_up = optional(object({
      min       = number
      max       = number
      desired   = number
      cron      = string
      time_zone = string
      }), {
      min       = 2
      max       = 3
      desired   = 2
      cron      = "0 9 * * MON-FRI" # 9AM every weekday UTC
      time_zone = "UTC"
    })
    cron_down = optional(object({
      min       = number
      max       = number
      desired   = number
      cron      = string
      time_zone = string
      }), {
      min       = 0
      max       = 0
      desired   = 0
      cron      = "0 18 * * MON-FRI" # 6PM every weekday UTC
      time_zone = "UTC"
    })
  }))
  description = "Map of EKS node group configurations"
}

variable "map_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default     = []
  description = "A list of aws-auth config-map"
}

variable "eks_sg_ingress" {
  type = object({
    ingress_rules = optional(map(object({
      from_port                = number
      to_port                  = number
      protocol                 = string
      cidr_blocks              = optional(list(string))
      source_security_group_id = optional(string)
      self                     = optional(bool)
      description              = optional(string)
    })), {})
  })
  default = {
    ingress_rules = {}
  }
  description = "Extra security group ingress rules for EKS cluster"
}

variable "eks_public_alb_sg_ingress" {
  type = map(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    description              = string
    source_security_group_id = optional(string, null)
    cidr_blocks              = optional(list(string), null)
  }))
  default     = {}
  description = "Ingress rules for shared EKS public ALB security group"
}

variable "eks_public_alb_to_nodes_ingress" {
  type = map(object({
    from_port   = number
    to_port     = number
    protocol    = optional(string, "tcp")
    description = string
  }))
  default     = {}
  description = "Allow shared EKS public ALB to reach node groups on pod ports"
}

variable "addons" {
  type = list(object({
    name    = string
    version = optional(string)
  }))
  default     = []
  description = "List of EKS addons to install"
}

variable "endpoint_public_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
}

variable "endpoint_private_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
}

variable "endpoint_public_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint. Ignored when endpoint_public_access is false"
}

variable "eks_admin_access" {
  type = object({
    admin_user = optional(string, null)
    ci_runner  = optional(string, null)
  })
  default     = {}
  description = "Access to the EKS cluster for admin users and CI runner"
}

variable "enable_kms" {
  type        = bool
  default     = false
  description = "Enable KMS encryption for EKS secrets and EBS volumes (plan-time toggle for IAM policies)"
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "KMS key ARN for EKS secrets envelope encryption and EBS volume encryption"
}


