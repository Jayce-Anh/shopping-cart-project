############################### VARIABLES #################################

#============== VPC ================#
variable "vpc_name" {
  type        = string
  default     = "vpc"
  description = "Name of the VPC"
}

variable "subnet_az" {
  type = map(object({
    az_index             = number
    public_subnet_count  = number
    private_subnet_count = number
  }))
  description = "Map of AZ configurations with subnet counts"
}

#========== Secret Manager ==========#
variable "secrets" {
  type = map(object({
    secret_name             = string
    secret_data             = optional(map(string), {})
    secret_string           = optional(string, null)
    use_initial_value       = optional(bool, true)
    recovery_window_in_days = optional(number, 30)
    description             = optional(string, null)
  }))
  validation {
    condition = alltrue([
      for _, v in var.secrets :
      v.secret_string == null || length(v.secret_data) == 0
    ])
    error_message = "Use either secret_string (plain text) or secret_data (JSON map)"
  }
  description = "Map of Secrets Manager secret configurations"
}

#========== ECR ==========#
variable "ecr_services" {
  type = map(object({
    name             = string
    keep_nums_images = optional(number, 10)
    force_del        = optional(bool, false)
  }))
  description = "Map of ECR services to per-repo settings"
}

#=========== Bastion ==========#
variable "bastion_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "Type of the instance"
}

variable "bastion_instance_name" {
  type        = string
  description = "Name of the instance"
}

variable "bastion_volume_size" {
  type        = number
  default     = 40
  description = "Size of the volume"
}

variable "bastion_capacity_type" {
  type        = string
  default     = "ON_DEMAND"
  description = "Single EC2 purchase option: ON_DEMAND or SPOT"
}

variable "bastion_path_user_data" {
  type        = string
  default     = "/scripts/user_data/debian/user_data.sh"
  description = "Path to user data script"
}

variable "ec2_key_name" {
  type        = string
  description = "Name of the existing key pair"
}

variable "bastion_sg_ingress" {
  type = map(object({
    from_port                = number
    to_port                  = number
    protocol                 = optional(string, "tcp")
    description              = string
    source_security_group_id = optional(string, null)
    cidr_blocks              = optional(list(string), ["0.0.0.0/0"])
  }))
  description = "Map of ingress rules for EC2 security group"
}

variable "bastion_enable_iam_access" {
  type = object({
    ssm            = optional(bool, true)
    ecr            = optional(bool, false)
    secretsmanager = optional(bool, false)
    s3             = optional(bool, false)
    eks            = optional(bool, false)
    ecs            = optional(bool, false)
  })
  default     = {}
  description = "IAM access control for Bastion EC2 instance"
}

variable "bastion_scheduler" {
  type = object({
    cron_start = optional(string, "cron(0 9 ? * MON-FRI *)")
    cron_stop  = optional(string, "cron(0 18 ? * MON-FRI *)")
    timezone   = optional(string, "Asia/Singapore")
  })
  default     = null
  nullable    = true
  description = "Scheduler settings for bastion EC2 stop/start (null = disabled)"
}

#=========== Gitlab Runner ==========#
variable "runner_instance_type" {
  type        = string
  default     = "t3a.large"
  description = "Instance type for GitLab runner"
}

variable "runner_instance_name" {
  type        = string
  default     = "gitlab-runner"
  description = "Name of the GitLab runner instance"
}

variable "runner_volume_size" {
  type        = number
  default     = 50
  description = "Root volume size for GitLab runner"
}

variable "runner_sg_ingress" {
  type = map(object({
    from_port                = number
    to_port                  = number
    protocol                 = optional(string, "tcp")
    description              = string
    source_security_group_id = optional(string, null)
    cidr_blocks              = optional(list(string), ["0.0.0.0/0"])
  }))
  description = "Ingress rules for GitLab runner security group"
}

variable "runner_ec2_enable_iam_access" {
  type = object({
    ssm            = optional(bool, true)
    ecr            = optional(bool, true)
    secretsmanager = optional(bool, false)
    s3             = optional(bool, false)
    eks            = optional(bool, false)
    ecs            = optional(bool, false)
  })
  default     = {}
  description = "IAM access control for GitLab runner EC2 instance"
}

variable "runner_path_user_data" {
  type        = string
  default     = "/scripts/user_data/debian/gitlab-runner.sh"
  description = "Path to user data script for GitLab runner EC2 instance"
}

#=========== CI/CD Runner IAM ==========#
variable "cicd_provider" {
  type    = string
  default = "gitlab"
  validation {
    condition     = contains(["gitlab", "github"], var.cicd_provider)
    error_message = "cicd_provider must be gitlab or github."
  }
  description = "CI/CD provider for OIDC federation: gitlab or github"
}

variable "runner_project_path" {
  type        = string
  description = "GitLab project path (group/project) or GitHub repo (org/repo) for OIDC subject claim"
}

variable "runner_project_scope" {
  type        = string
  default     = "/*"
  description = "GitHub repo scope for OIDC subject claim"
}

#=========== External ALB ==========#
variable "alb_name" {
  type        = string
  description = "Name of the load balancer"
}

variable "alb_enable_https_listener" {
  type        = bool
  default     = false
  description = "Enable HTTPS listener"
}

variable "alb_source_ingress_sg_cidr" {
  type        = list(string)
  description = "Source ingress security group CIDR"
}

variable "alb_target_groups" {
  type = map(object({
    name                  = string
    service_port          = number
    health_check_path     = string
    priority              = number
    path_patterns         = optional(list(string), null)
    host_header           = optional(string, null)
    protocol              = optional(string, "HTTP")
    health_check_protocol = optional(string, null)
    target_type           = optional(string, "ip")
    ec2_id                = optional(string, null)
  }))
  default     = {}
  description = "Map of target groups and listener rules for ALB"
}

#=========== Route53 ==========#
variable "hosted_zone_force_del" {
  type        = bool
  default     = false
  description = "Whether to destroy all records in the zone when deleting the hosted zone"
}

#=========== Cloudfront ==========#
variable "cf_service_name" {
  type        = string
  default     = "fe"
  description = "Name of the service for CloudFront"
}

variable "cf_s3_force_del" {
  type        = bool
  description = "Force destroy the S3 bucket"
}

variable "cf_custom_error_response" {
  type = list(object({
    error_code            = number
    response_code         = optional(number, null)
    response_page_path    = optional(string, null)
    error_caching_min_ttl = optional(number, null)
  }))
  default     = []
  description = "Custom error response"
}

#================== SQS ==================#
variable "sqs_name" {
  type        = string
  default     = "sqs"
  description = "Suffix for the SQS queue name"
}

variable "sqs_visibility_timeout" {
  type        = number
  default     = 30
  description = "SQS visibility timeout in seconds"
}

variable "sqs_message_retention_seconds" {
  type        = number
  default     = 345600
  description = "SQS message retention in seconds"
}

#================== RDS ==================#
variable "rds_name" {
  type        = string
  description = "Name of the RDS instance (alphanumeric only)"
}

variable "rds_multi_az" {
  type        = bool
  default     = false
  description = "Enable Multi-AZ deployment for the RDS instance"
}

variable "rds_enable_read_replica" {
  type        = bool
  default     = false
  description = "Create an RDS read replica and expose a reader endpoint"
}

variable "rds_read_replica_class" {
  type        = string
  default     = null
  nullable    = true
  description = "Instance class for the RDS read replica (defaults to primary class)"
}

variable "rds_storage_type" {
  type        = string
  default     = "gp3"
  description = "Storage type for the RDS instance (e.g. gp3, io1)"
}

variable "rds_iops" {
  type        = number
  default     = 3000
  description = "Provisioned IOPS for the RDS instance (used with gp3/io1)"
}

variable "rds_throughput" {
  type        = number
  default     = 125
  description = "Throughput in MiB/s for gp3 RDS storage"
}

variable "rds_storage" {
  type        = number
  default     = 30
  description = "Allocated storage size in GB for the RDS instance"
}

variable "rds_max_storage" {
  type        = number
  default     = 100
  description = "Maximum storage size in GB for RDS autoscaling"
}

variable "rds_username" {
  type        = string
  description = "Master username for the RDS instance"
}

variable "rds_port" {
  type        = number
  default     = 3306
  description = "Port number the RDS instance listens on"
}

variable "rds_class" {
  type        = string
  default     = "db.t4g.small"
  description = "Instance class for the RDS instance"
}

variable "rds_engine" {
  type        = string
  description = "Database engine for the RDS instance (e.g. mysql, postgres)"
}

variable "rds_engine_version" {
  type        = string
  description = "Engine version for the RDS instance"
}

variable "rds_backup_retention_period" {
  type        = number
  default     = 7
  description = "Number of days to retain automated RDS backups (0 = disabled)"
}

variable "rds_performance_insights_retention_period" {
  type        = number
  default     = 0
  description = "Retention period in days for Performance Insights (0 = disabled)"
}

variable "rds_family" {
  type        = string
  description = "Parameter group family for the RDS instance (e.g. mysql8.0)"
}

variable "rds_aws_db_parameters" {
  type        = map(any)
  description = "Custom parameter key-value pairs for the RDS parameter group"
}

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

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "KMS key ARN to encrypt RDS at-rest data (null = AWS managed key)"
}

#============= Valkey =============#
variable "cache_name" {
  type        = string
  description = "Name of the Valkey/ElastiCache cluster"
}

variable "cache_version" {
  type        = string
  default     = "valkey"
  description = "Engine version for the Valkey/ElastiCache cluster"
}

variable "cache_port" {
  type        = number
  default     = 6379
  description = "Port number the cache cluster listens on"
}

variable "cache_num_cache_nodes" {
  type        = number
  default     = 1
  description = "Number of cache nodes in the cluster"
}

variable "cache_node_type" {
  type        = string
  default     = "cache.t4g.small"
  description = "Instance type for the cache nodes"
}

variable "cache_family" {
  type        = string
  default     = "valkey7"
  description = "Parameter group family for the cache cluster"
}

variable "allowed_cidr_blocks_access_cache" {
  type        = list(string)
  default     = []
  description = "CIDR blocks allowed to access the cache cluster"
}

variable "cache_parameters" {
  type = map(string)
  default = {
    "maxmemory-policy" = "allkeys-lru"
  }
  description = "Custom parameter key-value pairs for the cache parameter group"
}

variable "cache_num_cache_clusters" {
  type        = number
  default     = 1
  description = "Number of cache clusters (nodes) in the replication group"
}

#==================== EKS ======================# 
variable "eks_name" {
  type        = string
  default     = "eks"
  description = "Name of the EKS cluster"
}

variable "eks_version" {
  type        = string
  description = "Version of the EKS cluster"
}

variable "eks_role_arns" {
  type        = list(string)
  default     = []
  description = "IAM role ARNs to grant EKS cluster admin access (e.g. GitLab CI runner role)"
}

variable "node_groups" {
  type = map(object({
    subnet_ids     = optional(list(string))
    min_size       = number
    max_size       = number
    desired_size   = number
    instance_types = optional(list(string))
    capacity_type  = optional(string, "ON_DEMAND")
    disk_size      = optional(number, 30)
    disk_type      = optional(string, "gp3")
    ami_type       = optional(string, "AL2023_x86_64_STANDARD")
    key_name       = optional(string)
    labels         = optional(map(string))
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
        description = "All outbound traffic (for pulling images, updates, etc.)"
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
  description = "EKS node group configurations"
}

variable "eks_sg_ingress" {
  type = map(object({
    from_port                = number
    to_port                  = number
    protocol                 = optional(string, "tcp")
    description              = string
    source_security_group_id = optional(string, null)
    cidr_blocks              = optional(list(string), ["0.0.0.0/0"])
  }))
  description = "Ingress rules for EKS cluster API security group"
}

variable "eks_admin_access" {
  type = object({
    admin_user = optional(string, null)
    ci_runner  = optional(string, null)
  })
  default     = {}
  description = "Access to the EKS cluster for admin users and CI runner"
}

#================= Helm ===================#
variable "helm_enable_addons" {
  type = object({
    argocd             = optional(string, null)
    cluster_autoscaler = optional(string, null)
    ex_secrets         = optional(string, null)
    karpenter          = optional(string, null)
  })
  default     = {}
  description = "Defind which addons to deploy"
}

variable "argocd_enable_git_credentials" {
  type        = bool
  default     = false
  description = "Set true after adding the GitLab PAT to Secrets Manager (helm-git-token secret)"
}

variable "argocd_git_token_secret" {
  type        = string
  default     = null
  description = "Secrets Manager secret name for the GitLab fine-grained PAT"
}

variable "argocd_git_repo_url" {
  type        = string
  default     = null
  description = "HTTPS URL of the Git repo ArgoCD watches"
}

variable "argocd_git_target_revision" {
  type        = string
  default     = "main"
  description = "Branch or tag ArgoCD syncs from"
}

variable "argocd_app_path" {
  type        = string
  default     = "./argocd/"
  description = "Path inside the repo for the ArgoCD Application manifests"
}

variable "argocd_cert_mode" {
  type    = string
  default = "insecure"
  validation {
    condition     = contains(["insecure", "secure"], var.argocd_cert_mode)
    error_message = "argocd_cert_mode must be insecure or secure."
  }
  description = "ArgoCD TLS mode: insecure (TLS at ALB) or secure (HTTPS to ArgoCD server)"
}

variable "helm_pod_identity_roles" {
  type = map(object({
    namespace       = optional(string)
    service_account = string
  }))
  default     = {}
  description = "App Pod Identity roles: service account in tfvars; policies wired in main.tf"
}

#================= KMS ===================#
variable "kms_enable_services" {
  type = object({
    rds            = optional(bool, false)
    elasticache    = optional(bool, false)
    ecr            = optional(bool, false)
    sqs            = optional(bool, false)
    secretsmanager = optional(bool, false)
    eks            = optional(bool, false)
    ec2            = optional(bool, false)
  })
  default     = {}
  description = "Per-service KMS toggle. true = CMK, false = no encryption / AWS-managed key"
}
