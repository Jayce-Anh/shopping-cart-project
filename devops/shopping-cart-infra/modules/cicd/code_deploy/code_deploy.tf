#----------------CodeDeploy application----------------
resource "aws_codedeploy_app" "codedeploy_app" {
  name             = "${var.project.env}-${var.project.name}-application"
  compute_platform = "Server" # Explicitly specify this is for EC2/on-premises
}

#------------------------CodeDeploy deployment group------------------------
resource "aws_codedeploy_deployment_group" "codedeploy_deployment_group" {
  app_name              = aws_codedeploy_app.codedeploy_app.name
  deployment_group_name = "${var.project.env}-${var.project.name}-deployment-group"
  service_role_arn      = var.codedeploy_role_arn

  #EC2 target filter
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

  #Deployment style (In-place with traffic control)
  deployment_style {
    deployment_type   = "IN_PLACE"
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
  }

  #Auto rollback configuration
  auto_rollback_configuration {
    enabled = false
    events  = ["DEPLOYMENT_FAILURE"]
  }

  #Deployment settings
  deployment_config_name = "CodeDeployDefault.OneAtATime"

  #Add alarm configuration
  alarm_configuration {
    alarms  = ["deployment-alarm"]
    enabled = true
  }
}