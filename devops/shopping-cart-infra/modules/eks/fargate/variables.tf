############################ VARIABLES ############################

#=========== Project ===========#
variable "project" {
  type = object({
    env         = string
    name        = string
    region      = string
    account_ids = list(string)
  })
  description = "Project metadata (env, name, region, account_ids)"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#======================= EKS =======================#
variable "eks_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "eks_version" {
  type        = string
  description = "Version"
}

variable "eks_subnet" {
  type        = list(string)
  description = "Subnet"
}

variable "fargates" {
  type = map(object({
    subnet_ids    = list(string)
    min-size      = number
    max_size      = number
    desired_size  = number
    instance_type = string
    disk_size     = number
    disk_type     = string
  }))
  default     = {}
  description = "Map of Fargate profiles configurations"
}

variable "extra_iam_policies" {
  type        = list(string)
  default     = []
  description = "Extra iam policies"
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

variable "addons" {
  type = list(object({
    name     = string
    version  = string
    role_arn = optional(string)
  }))
  description = "List of EKS addons to be installed"
}

variable "cluster_sg_ids" {
  type        = list(string)
  default     = []
  description = "Security group IDs attached to the EKS cluster"
}

variable "vpc_id" {
  type        = string
  description = "Vpc id"
}

variable "fargate_sg_ingress" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default     = []
  description = "Fargate sg ingress"
}

variable "endpoint_public_access" {
  type        = bool
  default     = false
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
}

variable "endpoint_private_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
}

variable "endpoint_public_access_cidrs" {
  type        = list(string)
  default     = null
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint. Ignored when cluster_endpoint_public_access is false"
}