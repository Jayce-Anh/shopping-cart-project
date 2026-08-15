############################# REMOTE STATE PROVIDER ############################

provider "aws" {
  region              = var.project.region
  allowed_account_ids = [var.project.account_id]
}