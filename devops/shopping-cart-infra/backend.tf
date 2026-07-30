######################### BACKEND CONFIGURATION #########################

terraform {
  backend "s3" {
    bucket = "lab-shopping-cart-tf-state"
    key    = "./terraform.tfstate"
    region = "ap-southeast-1"
    # dynamodb_table = "lab-shopping-cart-tf-state-locks"
    encrypt      = true
    use_lockfile = true
  }
}
