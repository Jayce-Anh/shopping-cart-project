############################ REMOTE STATE ############################

#============== S3 backend state ==============#
module "remote_state" {
  source  = "../modules/s3"
  project = var.project
  tags    = var.tags
}

