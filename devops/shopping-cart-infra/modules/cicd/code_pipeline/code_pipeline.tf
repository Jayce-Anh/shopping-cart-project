#-------------------------- S3 Bucket for CodePipeline artifact -------------------------- 
resource "aws_s3_bucket" "bucket_artifact" {
  bucket        = "${var.project.env}-${var.project.name}-${var.pipeline_name}-codepipeline-bucket"
  force_destroy = var.s3_force_del
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.pipeline_name}-codepipeline-bucket"
    Env  = "${var.project.env}"
  })
}

#-------------------------- CodePipeline --------------------------
resource "aws_codepipeline" "codepipeline" {
  name     = "${var.project.env}-${var.project.name}-${var.pipeline_name}-pipeline"
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
        Owner      = var.git_org
        Repo       = var.git_repo
        Branch     = var.git_branch
        OAuthToken = var.git_token
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
        ProjectName = var.project_name
      }
    }
  }

  #Conditional Deploy Stage (only for ECS deployments)
  dynamic "stage" {
    for_each = var.enable_ecs_deploy ? [1] : []
    content {
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
          ClusterName       = var.ecs_cluster_name
          ServiceName       = var.ecs_service_name
          FileName          = "artifact.json"
        }
      }
    }
  }

  # #Deploy Stage (CodeDeploy)
  #   stage {
  #     name = "Deploy"

  #     action {
  #       name             = "Deploy"
  #       category         = "Deploy"
  #       owner            = "AWS"
  #       provider         = "CodeDeploy"
  #       input_artifacts  = ["Build_Artifacts"]
  #       output_artifacts = ["Deploy_Artifacts"]
  #       version          = "1"

  #       configuration = {
  #         ApplicationName = var.application_name # CodeDeploy application name
  #         DeploymentGroupName = var.deployment_group_name # CodeDeploy deployment group name
  #       }
  #     }
  #   }

}

# A shared secret between GitHub and AWS that allows AWS
# CodePipeline to authenticate the request came from GitHub.
# Would probably be better to pull this from the environment
# or something like SSM Parameter Store.

#Generate a random secret token for the CodePipeline webhook
resource "random_string" "secret_token" {
  length  = 99
  special = false
}

#CodePipeline webhook
resource "aws_codepipeline_webhook" "bar" {
  name            = "${var.project.name}-${var.project.env}-${var.pipeline_name}-webhook"
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

