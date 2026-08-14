############################# REMOTE STATE PROVIDER ############################

provider "aws" {
  region              = local.project.region
  allowed_account_ids = [local.project.account_id]
}