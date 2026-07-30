######################## LOCAL CONFIGURATION ########################

locals {
  # Project configuration
  project = {
    name        = "shopping-cart"
    env         = "lab"
    region      = "ap-southeast-1"
    account_ids = ["701604998432"]
    domain      = "jayce-lab.works"
  }
  # Tags configuration
  tags = {
    Name      = "${local.project.env}-${local.project.name}"
    env       = "${local.project.env}"
    ManagedBy = "Terraform"
  }
  # Domain
  hostname = "${local.project.name}.${local.project.domain}"
  hostnames = {
    wildcard = "*.${local.hostname}"
    argocd   = "argocd.${local.hostname}"
    grafana  = "grafana.${local.hostname}"
    kibana   = "kibana.${local.hostname}"
  }
  # Repository
  helm_repo = "https://gitlab.com/shopping-cart796042412/devops/shoppingcart-manifest.git"
}

# Users
data "aws_iam_user" "admin_users" {
  user_name = "jayce-lab"
}

# Generate random passwords
resource "random_password" "generate" {
  for_each         = toset(["elastic", "grafana", "argocd", "rds"])
  length           = 16
  special          = true
  override_special = "_"
}

