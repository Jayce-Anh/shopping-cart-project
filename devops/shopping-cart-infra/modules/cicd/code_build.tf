################################# CICD - CODE BUILD #################################

resource "aws_codebuild_project" "project" {
  for_each     = local.cicd_services
  name         = "${var.project.env}-${var.project.name}-${each.key}"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    type            = "LINUX_CONTAINER"
    image           = "aws/codebuild/standard:6.0"
    privileged_mode = true

    dynamic "environment_variable" {
      for_each = local.codebuild_env_vars[each.key]
      content {
        name  = "${environment_variable.key}"
        value = "${environment_variable.value}"
      }
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline/lab-easyshop-${each.key}.yml")
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${each.key}"
    Env  = "${var.project.env}"
    Module = "${path.module}"
  })
}
