############################# TERRAFORM VARIABLES ############################

#=============== Project ================#
project = {
  name       = "shopping-cart"
  env        = "lab"
  region     = "ap-southeast-1"
  account_id = "701604998432"
  domain     = "jayce-lab.works"
  admin_user = "jayce-lab"
}

tags = {
  Environment = "lab"
  ManagedBy   = "Terraform"
  Owner       = "Jayce"
}

helm_repo = "https://gitlab.com/shopping-cart796042412/devops/shoppingcart-manifest.git"