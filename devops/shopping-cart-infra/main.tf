######################################## MAIN ##########################################

#=============== Hosted Zone =================#
module "hosted_zone" {
  source          = "./modules/route53"
  project         = var.project
  tags            = var.tags
  r53_domain_name = var.project.domain
}

#================= ACM Certificate =================#
module "acm" {
  source  = "./modules/acm"
  project = var.project
  tags    = var.tags
}

#================= Secret Manager =================#
module "secret_manager" {
  source         = "./modules/secret-manager"
  project        = var.project
  tags           = var.tags
  secret_kms_key = module.kms.key_arn
}

#================ VPC =================#
module "vpc" {
  source  = "./modules/vpc"
  project = var.project
  tags    = var.tags
}

#================= Bastion ==================#
module "bastion" {
  source          = "./modules/ec2/bastions"
  project         = var.project
  tags            = var.tags
  vpc_id          = module.vpc.vpc_id
  subnet_id       = module.vpc.public_subnet_ids[0]
  bastion_kms_key = module.kms.key_arn
}

#================= GitLab Runner ==================#
module "gitlab_runner" {
  source         = "./modules/ec2/gitlab-runner"
  project        = var.project
  tags           = var.tags
  vpc_id         = module.vpc.vpc_id
  subnet_id      = module.vpc.public_subnet_ids[0]
  runner_kms_key = module.kms.key_arn
}

#================= External ALB =================#
module "alb" {
  source         = "./modules/alb"
  project        = var.project
  tags           = var.tags
  alb_vpc_id     = module.vpc.vpc_id
  alb_subnet_ids = module.vpc.public_subnet_ids
  alb_dns_cert   = module.acm.cert_arns
}

#================= CloudFront =================#
module "cloudfront" {
  source          = "./modules/cloudfront"
  project         = var.project
  tags            = var.tags
  cf_alb_dns_name = module.alb.lb_dns_name
}

#================= KMS =================#
module "kms" {
  source  = "./modules/kms"
  project = var.project
  tags    = var.tags
}

#================= ECR =================#
module "ecr" {
  source       = "./modules/ecr"
  project      = var.project
  tags         = var.tags
  ecr_kms_key  = module.kms.key_arn
}

#================= RDS =================#
module "rds" {
  source         = "./modules/database/rds"
  project        = var.project
  tags           = var.tags
  rds_vpc_id     = module.vpc.vpc_id
  rds_subnet_ids = module.vpc.private_subnet_ids
  rds_allowed_sg = [module.bastion.sg_id, module.eks.node_group_sg_id]
  rds_kms_key    = module.kms.key_arn
}

#================= Valkey =================#
module "valkey" {
  source           = "./modules/database/elasticache"
  project          = var.project
  tags             = var.tags
  cache_vpc_id     = module.vpc.vpc_id
  cache_subnet_ids = module.vpc.private_subnet_ids
  cache_allowed_sg = [module.bastion.sg_id, module.eks.node_group_sg_id]
  cache_kms_key    = module.kms.key_arn
}

#================= EKS =================#
module "eks" {
  source         = "./modules/eks"
  project        = var.project
  tags           = var.tags
  eks_vpc_id     = module.vpc.vpc_id
  eks_subnet_ids = module.vpc.private_subnet_ids
  eks_kms_key    = module.kms.key_arn
  eks_allowed_sg = [module.bastion.sg_id, module.gitlab_runner.sg_id]
  eks_alb_sg_id  = module.alb.lb_sg_id
  eks_admin_access = {
    bastion       = module.bastion.role_arn
    gitlab_ci     = module.gitlab_runner.ci_provider_role_arn
    gitlab_runner = module.gitlab_runner.role_arn
    admin_user    = data.aws_iam_user.admin_user.arn
  }
}

#================= Helm =================#
module "helm" {
  source                  = "./modules/helm"
  project                 = var.project
  tags                    = var.tags
  helm_eks_cluster        = module.eks.eks_cluster_name
  helm_vpc_id             = module.vpc.vpc_id
  helm_kms_key            = module.kms.key_arn
  helm_repo_url           = var.helm_repo
  helm_argocd_tg_arn      = module.alb.tg_arns["argocd"]
  helm_sqs_queue_arn      = module.sqs.sqs_queue_arn
  helm_rds_secret_arn     = module.rds.rds_secret_arn
  helm_eks_node_group_id  = module.eks.node_group_id
}

#================= SQS =================#
module "sqs" {
  source = "./modules/sqs"
  project = var.project
  tags = var.tags
  sqs_kms_key = module.kms.key_arn
}