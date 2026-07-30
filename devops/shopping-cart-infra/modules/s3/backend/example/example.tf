############################ MAIN ############################

#============== S3 backend state ==============#
module "backend" {
  source  = "../modules/s3/backend"
  project = local.project
  tags    = local.tags
}

#============== DynamoDB state lock (Optional) ==============#
module "state_lock" {
  source  = "../modules/database/dynamodb/tf_state_lock"
  project = local.project
  tags    = local.tags
}