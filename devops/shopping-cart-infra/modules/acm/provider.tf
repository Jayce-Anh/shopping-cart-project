##################### PROVIDER #####################

provider "aws" {
  region              = var.acm_region
  allowed_account_ids = var.project.account_ids
}
