############### LOCAL CONFIGURATIONS ################
locals {
  project = {
    name        = "shopping-cart"
    env         = "lab"
    region      = "ap-southeast-1"
    account_ids = ["701604998432"]
  }

  tags = {
    Name        = "${local.project.env}-${local.project.name}"
    Environment = "${local.project.env}"
    ManagedBy   = "Terraform"
  }
}

