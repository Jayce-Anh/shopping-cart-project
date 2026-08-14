############################# REMOTE STATE PROJECT ############################

locals {
  # Project configuration
  project = {
    name       = "shopping-cart"
    env        = "lab"
    region     = "ap-southeast-1"
    account_id = "701604998432"
    domain     = "jayce-lab.works"
  }
  # Tags configuration
  tags = {
    Name      = "${local.project.env}-${local.project.name}"
    env       = "${local.project.env}"
    ManagedBy = "Terraform"
  }
}