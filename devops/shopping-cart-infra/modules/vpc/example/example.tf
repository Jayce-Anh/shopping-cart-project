############################ VPC ############################
module "vpc" {
  source     = "../modules/vpc"
  project    = local.project
  tags       = local.tags
  cidr_block = var.cidr_block
  subnet_az  = var.subnet_az
}