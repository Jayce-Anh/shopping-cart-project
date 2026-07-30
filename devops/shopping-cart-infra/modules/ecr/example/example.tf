#################### EXAMPLE ####################

#============== ECR =============#
module "ecr" {
  source       = "./modules/ecr"
  project      = local.project
  tags         = local.tags
  ecr_services = var.ecr_services
}