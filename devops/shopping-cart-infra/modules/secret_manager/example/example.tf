module "secret_manager" {
  source  = "./modules/secret_manager"
  project = local.project
  tags    = local.tags
  secrets = var.secrets
}