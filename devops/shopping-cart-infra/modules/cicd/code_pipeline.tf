################################# CICD - CODE PIPELINE #################################

#================= S3 Bucket =================#
resource "aws_s3_bucket" "bucket_artifact" {
  bucket        = "${var.project.env}-${var.project.name}-codepipeline"
  force_destroy = true
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-codepipeline"
    Env  = "${var.project.env}"
  })
}

#================= CodePipeline =================#
resource "aws_codepipeline" "codepipeline" {
  name     = "${var.project.env}-${var.project.name}"
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.bucket_artifact.bucket
    type     = "S3"
  }

  #Source Stage
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["Source_Artifacts"]

      configuration = {
        Owner      = var.git_config.org
        Repo       = var.git_config.repo
        Branch     = var.git_config.branch
        OAuthToken = var.git_config.token
      }
    }
  }

  #Build Stage
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["Source_Artifacts"]
      output_artifacts = ["Build_Artifacts"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild.name
      }
    }
  }

  #Conditional Deploy Stage (only for ECS deployments)
  stage {
    name = "Deploy"
    
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["Build_Artifacts"]
      version         = "1"
      configuration = {
        DeploymentTimeout = "20"
        ClusterName       = ""
        ServiceName       = ""
        FileName          = "artifact.json"
      }
    }
  }
}

#================= Webhook =================#
# Generate a random secret token for the CodePipeline webhook
resource "random_string" "secret_token" {
  length  = 99
  special = false
}

#CodePipeline webhook
resource "aws_codepipeline_webhook" "bar" {
  name            = "${var.project.name}-${var.project.env}-webhook"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.codepipeline.name

  authentication_configuration {
    secret_token = random_string.secret_token.result
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}


## Wire the CodePipeline webhook into a GitHub repository.
#resource "github_repository_webhook" "bar" {
#  repository = var.gitRepo
#
#  configuration {
#    url          = aws_codepipeline_webhook.bar.url
#    content_type = "json"
#    insecure_ssl = false
#    secret       = random_string.secret_token.result
#  }
#
#  events = ["push"]
#}

