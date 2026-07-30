######################### CODE BUILD #########################
resource "aws_codebuild_project" "codebuild" {
  name         = "${var.project.env}-${var.project.name}-${var.build_name}-project"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    image           = "aws/codebuild/standard:5.0"
    privileged_mode = true
    type            = "LINUX_CONTAINER"
    dynamic "environment_variable" {
      for_each = var.env_vars_codebuild
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = file(var.buildspec_file)
  }
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.build_name}-project"
    Env  = "${var.project.env}"
  })
}