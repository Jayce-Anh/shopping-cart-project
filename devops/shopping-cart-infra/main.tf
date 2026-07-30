############################ MAIN ################################

#========== Route53 ==========# 
module "route53" {
  source                        = "./modules/route53"
  project                       = local.project
  tags                          = local.tags
  route53_domain_name           = local.project.domain
  route53_hosted_zone_force_del = var.hosted_zone_force_del
}

#========== ACM ==========#
module "acm_alb" {
  source     = "./modules/acm"
  project    = local.project
  tags       = local.tags
  acm_region = local.project.region
  acm_certs = {
    alb = {
      domain = local.hostnames.wildcard
    }
  }
}

module "acm_cf" {
  source     = "./modules/acm"
  project    = local.project
  tags       = local.tags
  acm_region = "us-east-1"
  acm_certs = {
    cf = {
      domain = local.hostname
    }
  }
}

#========== VPC ===========#
module "vpc" {
  source    = "./modules/vpc"
  project   = local.project
  tags      = local.tags
  vpc_name  = var.vpc_name
  subnet_az = var.subnet_az
}


#========== KMS ===========#
module "kms" {
  source              = "./modules/kms"
  project             = local.project
  tags                = local.tags
  kms_enable_services = var.kms_enable_services
}

#============== ECR =============#
module "ecr" {
  source       = "./modules/ecr"
  project      = local.project
  tags         = local.tags
  ecr_services = var.ecr_services
  kms_key_arn  = module.kms.ecr_key_arn
}

#============== Bastion ===============#
module "bastion" {
  source                = "./modules/ec2"
  project               = local.project
  tags                  = local.tags
  ec2_vpc_id            = module.vpc.vpc_id
  ec2_subnet_id         = module.vpc.public_subnet_ids[0]
  ec2_instance_type     = var.bastion_instance_type
  ec2_instance_name     = var.bastion_instance_name
  ec2_key_name          = var.ec2_key_name
  ec2_volume_size       = var.bastion_volume_size
  ec2_capacity_type     = var.bastion_capacity_type
  ec2_sg_ingress        = var.bastion_sg_ingress
  ec2_path_user_data    = "${path.root}${var.bastion_path_user_data}"
  ec2_enable_iam_access = var.bastion_enable_iam_access

  ec2_scheduler = var.bastion_scheduler
}

#============== Gitlab Runner ===============#
module "gitlab_runner" {
  source                = "./modules/ec2"
  project               = local.project
  tags                  = local.tags
  ec2_vpc_id            = module.vpc.vpc_id
  ec2_subnet_id         = module.vpc.public_subnet_ids[0]
  ec2_instance_type     = var.runner_instance_type
  ec2_instance_name     = var.runner_instance_name
  ec2_key_name          = var.ec2_key_name
  ec2_volume_size       = var.runner_volume_size
  ec2_sg_ingress        = var.runner_sg_ingress
  ec2_path_user_data    = "${path.root}${var.runner_path_user_data}"
  ec2_enable_iam_access = var.runner_ec2_enable_iam_access
}

#================ CI Runner IAM =================#
module "runner_role" {
  source = "./modules/iam/ci-runner"

  cicd_provider       = var.cicd_provider
  project             = local.project
  tags                = local.tags
  runner_project_path = var.runner_project_path
  runner_ec2_role_arn = module.gitlab_runner.ec2_role_arn
}

#============== External ALB ===============#
module "alb" {
  source                     = "./modules/alb/external"
  project                    = local.project
  tags                       = local.tags
  alb_name                   = var.alb_name
  alb_vpc_id                 = module.vpc.vpc_id
  alb_dns_cert               = module.acm_alb.cert_arns["alb"]
  alb_enable_https_listener  = var.alb_enable_https_listener
  alb_subnet_ids             = module.vpc.public_subnet_ids
  alb_source_ingress_sg_cidr = var.alb_source_ingress_sg_cidr
  alb_target_groups = merge(var.alb_target_groups, {
    argocd = merge(var.alb_target_groups["argocd"], {
      host_header = local.hostnames.argocd
    })
    grafana = merge(var.alb_target_groups["grafana"], {
      host_header = local.hostnames.grafana
    })
    kibana = merge(var.alb_target_groups["kibana"], {
      host_header = local.hostnames.kibana
    })
  })
}

#============== Cloudfront ==============#
module "cloudfront" {
  source                   = "./modules/cloudfront/path-base-routing"
  project                  = local.project
  tags                     = local.tags
  cf_service_name          = var.cf_service_name
  cf_cert_arn              = module.acm_cf.cert_arns["cf"]
  cf_s3_force_del          = var.cf_s3_force_del
  cf_aliases               = [local.hostname]
  cf_custom_error_response = var.cf_custom_error_response
  cf_alb_dns_name          = module.alb.lb_dns_name
}

#================ SQS =================#
module "sqs" {
  source                        = "./modules/sqs"
  project                       = local.project
  tags                          = local.tags
  sqs_name                      = var.sqs_name
  sqs_visibility_timeout        = var.sqs_visibility_timeout
  sqs_message_retention_seconds = var.sqs_message_retention_seconds
  kms_key_arn                   = module.kms.sqs_key_arn
}

#================ RDS =================#
module "rds" {
  source         = "./modules/database/rds"
  project        = local.project
  tags           = local.tags
  rds_vpc_id     = module.vpc.vpc_id
  rds_subnet_ids = module.vpc.private_subnet_ids
  rds_name       = var.rds_name
  multi_az       = var.rds_multi_az
  rds_allowed_sg_ids_access = concat(
    [module.bastion.ec2_sg_id],
    module.eks.node_group_sg_ids
  )

  rds_storage     = var.rds_storage
  rds_max_storage = var.rds_max_storage

  rds_username = var.rds_username
  rds_password = random_password.generate["rds"].result

  rds_class                                 = var.rds_class
  rds_engine                                = var.rds_engine
  rds_engine_version                        = var.rds_engine_version
  rds_port                                  = var.rds_port
  rds_backup_retention_period               = var.rds_backup_retention_period
  rds_performance_insights_retention_period = var.rds_performance_insights_retention_period

  rds_family            = var.rds_family
  rds_aws_db_parameters = var.rds_aws_db_parameters
  kms_key_arn           = module.kms.rds_key_arn

  rds_scheduler = var.rds_scheduler
}

#============== Secret Manager =============#
module "secret_manager" {
  source  = "./modules/secret_manager"
  project = local.project
  tags    = local.tags

  secrets = merge(var.secrets, {
    mysql = merge(var.secrets["mysql"], {
      secret_data = {
        DATABASE_USERNAME = "${var.rds_username}"
        DATABASE_PASSWORD = "${random_password.generate["rds"].result}"
        DATABASE_HOST     = "${module.rds.rds_address}"
        DATABASE_PORT     = module.rds.db_port
      }
    })
    helm_addon_credentials = merge(var.secrets["helm_addon_credentials"], {
      secret_data = {
        elastic_password  = "${random_password.generate["elastic"].result}"
        grafana_password  = "${random_password.generate["grafana"].result}"
        argocd_password   = "${random_password.generate["argocd"].result}"
      }
    })
  })
  kms_key_arn = module.kms.secretsmanager_key_arn
}

#============== Valkey ===============#
module "valkey" {
  source                           = "./modules/database/elasticache"
  project                          = local.project
  tags                             = local.tags
  vpc_id                           = module.vpc.vpc_id
  subnet_ids                       = module.vpc.private_subnet_ids
  cache_name                       = var.cache_name
  cache_version                    = var.cache_version
  cache_port                       = var.cache_port
  cache_num_cache_clusters         = var.cache_num_cache_clusters
  cache_node_type                  = var.cache_node_type
  cache_family                     = var.cache_family
  allowed_cidr_blocks_access_cache = var.allowed_cidr_blocks_access_cache
  allowed_sg_ids_access_cache      = module.eks.node_group_sg_ids
  cache_parameters                 = var.cache_parameters
  kms_key_arn                      = module.kms.elasticache_key_arn
}

#============== EKS ===============#
module "eks" {
  source      = "./modules/eks/node_group"
  project     = local.project
  tags        = local.tags
  eks_name    = local.project.name
  eks_version = var.eks_version
  eks_vpc     = module.vpc.vpc_id
  eks_subnet  = module.vpc.private_subnet_ids
  eks_sg_ingress = {
    ingress_rules = {
      gitlab_runner = merge(var.eks_sg_ingress.gitlab_runner, {
        source_security_group_id = module.gitlab_runner.ec2_sg_id
      })
      bastion = merge(var.eks_sg_ingress.bastion, {
        source_security_group_id = module.bastion.ec2_sg_id
      })
    }
  }
  node_groups = {
    default = merge(var.node_groups.default, {
      subnet_ids = module.vpc.private_subnet_ids
      ingress_rules = {
        services = merge(var.node_groups.default.ingress_rules.services, {
          source_security_group_id = module.alb.lb_sg_id
        })
        argocd = merge(var.node_groups.default.ingress_rules.argocd, {
          source_security_group_id = module.alb.lb_sg_id
        })
        grafana = merge(var.node_groups.default.ingress_rules.grafana, {
          source_security_group_id = module.alb.lb_sg_id
        })
        kibana = merge(var.node_groups.default.ingress_rules.kibana, {
          source_security_group_id = module.alb.lb_sg_id
        })
      }
    })
  }
  eks_admin_access = {
    admin_user = data.aws_iam_user.admin_users.arn
    ci_runner  = module.runner_role.runner_role_arn
  }
  enable_kms  = var.kms_enable_services.eks
  kms_key_arn = module.kms.eks_key_arn
}

#==================== HELM ======================#
module "helm" {
  source = "./modules/helm"

  project             = local.project
  tags                = local.tags
  helm_eks_cluster_id = module.eks.eks_cluster_id
  helm_vpc_id         = module.vpc.vpc_id
  helm_enable_addons  = var.helm_enable_addons

  # ArgoCD config
  argocd_target_group_arn    = module.alb.tg_arns["argocd"]
  argocd_cert_mode           = var.argocd_cert_mode
  argocd_hostname            = local.hostnames.argocd
  argocd_git_token_secret    = module.secret_manager.secret_names["helm_git_token"]
  argocd_git_repo_url        = local.helm_repo
  argocd_git_target_revision = var.argocd_git_target_revision
  argocd_app_path            = var.argocd_app_path
  argocd_admin_password = random_password.generate["argocd"].result
  enable_kms            = var.kms_enable_services.secretsmanager
  kms_key_arn           = module.kms.secretsmanager_key_arn

  helm_pod_identity_roles = {
    inventory = merge(var.helm_pod_identity_roles.inventory, {
      namespace = local.project.name
      inline_policies = {
        sqs-access = {
          resources = [module.sqs.sqs_queue_arn]
        }
      }
    })
    order = merge(var.helm_pod_identity_roles.order, {
      namespace = local.project.name
      inline_policies = {
        sqs-access = {
          resources = [module.sqs.sqs_queue_arn]
        }
      }
    })
  }
  depends_on = [module.eks, module.sqs, module.secret_manager, module.alb]
}
