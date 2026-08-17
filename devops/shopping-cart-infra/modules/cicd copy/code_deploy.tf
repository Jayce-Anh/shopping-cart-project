################################# CICD - CODE DEPLOY #################################

#================= CodeDeploy Application =================#
# resource "aws_codedeploy_app" "codedeploy_app" {
#   name             = "${var.project.env}-${var.project.name}"
#   compute_platform = "Server"
# }

# resource "aws_codedeploy_deployment_group" "codedeploy_deployment_group" {
#   app_name              = aws_codedeploy_app.codedeploy_app.name
#   deployment_group_name = "${var.project.env}-${var.project.name}"
#   service_role_arn      = aws_iam_role.deployment_group_role.arn

#   ec2_tag_set {
#     ec2_tag_filter {
#       key   = "Name"
#       type  = "KEY_AND_VALUE"
#       value = "" # Instance name
#     }
#     ec2_tag_filter {
#       key   = "Environment"
#       type  = "KEY_AND_VALUE"
#       value = var.project.env
#     }
#     ec2_tag_filter {
#       key   = "CodeDeploy"
#       type  = "KEY_AND_VALUE"
#       value = "true"
#     }
#   }

#   deployment_style {
#     deployment_type   = "IN_PLACE"
#     deployment_option = "WITHOUT_TRAFFIC_CONTROL"
#   }

#   auto_rollback_configuration {
#     enabled = false
#     events  = ["DEPLOYMENT_FAILURE"]
#   }

#   deployment_config_name = "CodeDeployDefault.OneAtATime"
# }
