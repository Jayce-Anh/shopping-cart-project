################################ PROVIDER ##################################

provider "aws" {
  region              = var.project.region
  allowed_account_ids = [var.project.account_id]
}

data "aws_iam_user" "admin_user" {
  user_name = var.project.admin_user
}
