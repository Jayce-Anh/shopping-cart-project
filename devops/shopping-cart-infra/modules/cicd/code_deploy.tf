#----------------CodeDeploy application (EC2, optional)----------------
resource "aws_codedeploy_app" "codedeploy_app" {
  count = var.enable_codedeploy ? 1 : 0

  name             = "${var.project.env}-${var.project.name}-${var.pipeline_name}-application"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "codedeploy_deployment_group" {
  count = var.enable_codedeploy ? 1 : 0

  app_name              = aws_codedeploy_app.codedeploy_app.name
  deployment_group_name = "${var.project.env}-${var.project.name}-${var.pipeline_name}-deployment-group"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = var.instance_codedeploy
    }
    ec2_tag_filter {
      key   = "Environment"
      type  = "KEY_AND_VALUE"
      value = var.project.env
    }
    ec2_tag_filter {
      key   = "CodeDeploy"
      type  = "KEY_AND_VALUE"
      value = "true"
    }
  }

  deployment_style {
    deployment_type   = "IN_PLACE"
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
  }

  auto_rollback_configuration {
    enabled = false
    events  = ["DEPLOYMENT_FAILURE"]
  }

  deployment_config_name = "CodeDeployDefault.OneAtATime"
}
