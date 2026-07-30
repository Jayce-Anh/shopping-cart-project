#################### TERRAFORM.TFVARS #######################

#=========== VPC ===========#
subnet_az = {
  "ap-southeast-1a" = {
    az_index             = 0
    public_subnet_count  = 1
    private_subnet_count = 1
  }
  "ap-southeast-1b" = {
    az_index             = 1
    public_subnet_count  = 1
    private_subnet_count = 1
  }
}

#============== Secret Manager =============#
secrets = {
  mysql = {
    secret_name             = "rds-credentials"
    use_initial_value       = false
    recovery_window_in_days = 0
    description             = "RDS credentials for application"
  }
  helm_git_token = {
    secret_name             = "helm-git-token"
    recovery_window_in_days = 0
    description             = "GitLab token of Helm repository for ArgoCD"
    secret_string           = "replace-me-with-actual-gitlab-token-123" # Manually replace with actual GitLab token, then apply Helm module again
  }
  gitlab_runner = {
    secret_name             = "gitlab-runner-token"
    recovery_window_in_days = 0
    description             = "GitLab token registered of GitLab runner"
  }
  helm_addon_credentials = {
    secret_name             = "helm-addon-credentials"
    use_initial_value       = false
    recovery_window_in_days = 0
    description             = "Password of Helm addons"
    secret_data = {
      webhook_url = "replace-me-with-actual-webhook-url-123" # Manually replace with actual webhook URL, then apply Helm module again
    }
  }
}

#============== ECR ==============#
ecr_services = {
  catalog = {
    name             = "catalog"
    keep_nums_images = 3
    force_del        = true
  }
  inventory = {
    name             = "inventory"
    keep_nums_images = 3
    force_del        = true
  }
  order = {
    name             = "order"
    keep_nums_images = 3
    force_del        = true
  }
}

#============== Route53 ==============#
hosted_zone_force_del = true

#============== CloudFront ==============#
cf_service_name = "web-ui"
cf_s3_force_del = true
cf_custom_error_response = [
  {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  },
  {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }
]

#============== Bastion ==============#
bastion_instance_type = "t3.small"
bastion_instance_name = "bastion"
bastion_capacity_type = "SPOT"
bastion_volume_size   = 20
ec2_key_name          = "lab-jayce"
bastion_sg_ingress = {
  ssh = {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Allow SSH for bastion"
  }
}
bastion_enable_iam_access = {
  secretsmanager = true
  eks            = true
  ecr            = true
  s3             = true
}

#============= Gitlab Runner ==============#
runner_instance_type = "t3a.medium"
runner_instance_name = "gitlab-runner"
runner_volume_size   = 40
runner_sg_ingress = {
  ssh = {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Allow SSH for GitLab runner"
  }
}
runner_ec2_enable_iam_access = {
  secretsmanager = true
  eks            = true
}

#============= CI/CD Runner IAM ==============#
cicd_provider       = "gitlab"
runner_project_path = "shopping-cart"


#============== External ALB ===============#
alb_name                   = "external-alb"
alb_source_ingress_sg_cidr = ["0.0.0.0/0"]
alb_enable_https_listener  = true
alb_target_groups = {
  catalog = {
    name              = "catalog"
    service_port      = 4000
    health_check_path = "/api/products"
    priority          = 10
    path_patterns     = ["/api/products", "/api/products/*"]
  }
  order = {
    name              = "order"
    service_port      = 6000
    health_check_path = "/api/orders"
    priority          = 20
    path_patterns     = ["/api/orders", "/api/orders/*"]
  }
  inventory = {
    name              = "inventory"
    service_port      = 5000
    health_check_path = "/api/inventory"
    priority          = 30
    path_patterns     = ["/api/inventory", "/api/inventory/*"]
  }
  argocd = {
    name                  = "argocd"
    service_port          = 443
    protocol              = "HTTPS"
    health_check_protocol = "HTTPS"
    health_check_path     = "/healthz"
    priority              = 40
  }
  grafana = {
    name                  = "grafana"
    service_port          = 8090
    protocol              = "HTTPS"
    health_check_protocol = "HTTPS"
    health_check_path     = "/api/health"
    priority              = 50
  }
  kibana = {
    name                  = "kibana"
    service_port          = 5601
    protocol              = "HTTPS"
    health_check_protocol = "HTTPS"
    health_check_path     = "/login"
    priority              = 60
  }
}

#================ SQS ===============#
sqs_name                      = "order-events"
sqs_visibility_timeout        = 30
sqs_message_retention_seconds = 3600

#================ RDS ===============#
rds_name           = "mysqldb"
rds_class          = "db.t4g.micro"
rds_engine         = "mysql"
rds_engine_version = "8.0"
rds_family         = "mysql8.0"
rds_username       = "admin"
rds_port           = 3306
rds_aws_db_parameters = {
  "max_connections"          = 500
  "require_secure_transport" = 0
}

#================ Valkey ================#
cache_name      = "valkey"
cache_version   = "7.2"
cache_node_type = "cache.t4g.micro"
cache_family    = "valkey7"

#================ EKS ===============#
eks_version = "1.35"
eks_sg_ingress = {
  gitlab_runner = {
    from_port   = 443
    to_port     = 443
    description = "GitLab runner to EKS API"
  }
  bastion = {
    from_port   = 443
    to_port     = 443
    description = "Bastion to EKS API"
  }
}

node_groups = {
  default = {
    min_size       = 2
    max_size       = 4
    desired_size   = 3
    instance_types = ["t3.medium", "t3a.medium"]
    capacity_type  = "SPOT"
    disk_size      = 20
    disk_type      = "gp3"
    ingress_rules = {
      services = {
        from_port   = 4000
        to_port     = 6000
        protocol    = "tcp"
        description = "Allow traffic from external ALB to Service pods"
      }
      argocd = {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        description = "Allow traffic from external ALB to ArgoCD pods"
      }
      grafana = {
        from_port   = 8090
        to_port     = 8090
        protocol    = "tcp"
        description = "Allow traffic from external ALB to Kibana pods"
      }
      kibana = {
        from_port   = 5601
        to_port     = 5601
        protocol    = "tcp"
        description = "Allow traffic from external ALB to Grafana pods"
      }
    }
  }
}

#================= Helm ===================#
helm_enable_addons = {
  argocd             = true
  cluster_autoscaler = true
  ex_secrets         = true
}

# ArgoCD config 
argocd_app_path            = "argocd/"
argocd_git_target_revision = "main"
argocd_cert_mode           = "secure"

# Pod Identity roles for app service accounts (inventory, order)
helm_pod_identity_roles = {
  inventory = {
    service_account = "inventory"
  }
  order = {
    service_account = "order"
  }
}

#================ KMS ================#
kms_enable_services = {
  rds            = true
  elasticache    = true
  ecr            = true
  sqs            = true
  secretsmanager = true
  eks            = true
  ec2            = false
}

