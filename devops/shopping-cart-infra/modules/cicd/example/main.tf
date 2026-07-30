#-------------------FE pipeline----------------
#S3 - CloudFront pipeline
module "pipeline_fe" {
  source            = "./modules/cicd/code_pipeline"
  project           = local.project
  tags              = local.tags
  project_name      = module.build_fe.project_name
  git_org           = local.git_repo.fe.organization
  git_repo          = local.git_repo.fe.name
  git_branch        = local.git_repo.fe.branch
  pipeline_name     = "fe"
  git_token         = var.github_token
  enable_ecs_deploy = false
}

module "build_fe" {
  source         = "./modules/cicd/code_build"
  project        = local.project
  tags           = local.tags
  build_name     = "fe"
  buildspec_file = "${path.root}/scripts/pipeline/fe-buildspec.yml"
  env_vars_codebuild = {
    S3_BUCKET_NAME  = "${module.cloudfront.cfs3_bucket}"
    DISTRIBUTION_ID = "${module.cloudfront.distribution_id}"
    PARAMETER_STORE = "${module.parameter_store.parameter_name["fe"]}"
    GITHUB_TOKEN    = "${var.github_token}"
    GITHUB_REPO     = "${local.git_repo.fe.name}"
    GITHUB_BRANCH   = "${local.git_repo.fe.branch}"
    GITHUB_ORG      = "${local.git_repo.fe.organization}"
    REGION          = "${local.project.region}"
  }
}

# -------------------BE pipeline----------------
#ECS pipeline
module "pipeline_be" {
  source            = "./modules/cicd/code_pipeline"
  project           = local.project
  tags              = local.tags
  project_name      = module.build_be.project_name
  git_org           = local.git_repo.be.organization
  git_repo          = local.git_repo.be.name
  git_branch        = local.git_repo.be.branch
  pipeline_name     = "be"
  git_token         = var.github_token
  enable_ecs_deploy = true
  ecs_cluster_name  = module.ecs.cluster_name
  ecs_service_name  = module.ecs.service_name["be"]
}

module "build_be" {
  source         = "./modules/cicd/code_build"
  project        = local.project
  tags           = local.tags
  build_name     = "be"
  buildspec_file = "${path.root}/scripts/pipeline/be-buildspec.yml"
  env_vars_codebuild = {
    REGISTRY_URL     = "${module.ecr.ecr_url}"
    SERVICE          = "${module.ecs.service_name["be"]}"
    REGION           = "${local.project.region}"
    SSM_ENV          = "${module.parameter_store.parameter_name["be"]}"
    ECS_CLUSTER_NAME = "${module.ecs.cluster_name}"
    CONTAINER_NAME   = "${local.project.env}-${local.project.name}-be"
    ECR_IMAGE_TAG    = "latest"
    ECR_URL          = "${module.ecr.ecr_url}"
  }
}