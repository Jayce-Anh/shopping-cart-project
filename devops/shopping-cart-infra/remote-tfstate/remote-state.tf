############################ REMOTE STATE ############################

#============== S3 backend state ==============#
module "remote_state" {
  source  = "../modules/s3/remote-state"
  project = local.project
  tags    = local.tags
}

