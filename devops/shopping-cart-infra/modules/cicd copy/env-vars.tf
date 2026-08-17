################################# CODE BUILD ENVIRONMENT VARIABLES ################################

locals {
  cicd_services = toset(["web-ui", "auth", "product", "cart"])

  web_ui_env_vars = {
    S3_BUCKET_NAME      = "${var.cicd_ui_env.s3_bucket_name}"
    DISTRIBUTION_ID     = "${var.cicd_ui_env.distribution_id}"
    SECRET_MANAGER      = "${var.cicd_ui_env.secret_manager}"
    REGION              = "${var.project.region}"
  }

  auth_env_vars = {
    ECR_URL          = "${var.cicd_auth_env.ecr_url}"
    ECS_CLUSTER_NAME = "${var.cicd_auth_env.ecs_cluster_name}"
    SERVICE          = "auth"
    CONTAINER_NAME   = "${var.cicd_auth_env.container_name}"
    SECRET_MANAGER   = "${var.cicd_auth_env.secret_manager}"
    REGION           = "${var.project.region}"
  }

  product_env_vars = {
    ECR_URL          = "${var.cicd_product_env.ecr_url}"
    ECS_CLUSTER_NAME = "${var.cicd_product_env.ecs_cluster_name}"
    SERVICE          = "product"
    CONTAINER_NAME   = "${var.cicd_product_env.container_name}"
    SECRET_MANAGER   = "${var.cicd_product_env.secret_manager}"
    REGION           = "${var.project.region}"
  }

  cart_env_vars = {
    ECR_URL          = "${var.cicd_cart_env.ecr_url}"
    ECS_CLUSTER_NAME = "${var.cicd_cart_env.ecs_cluster_name}"
    SERVICE          = "cart"
    CONTAINER_NAME   = "${var.cicd_cart_env.container_name}"
    SECRET_MANAGER   = "${var.cicd_cart_env.secret_manager}"
    REGION           = "${var.project.region}"
  }

  codebuild_env_vars = {
    web-ui  = local.web_ui_env_vars
    auth    = local.auth_env_vars
    product = local.product_env_vars
    cart    = local.cart_env_vars
  }
}