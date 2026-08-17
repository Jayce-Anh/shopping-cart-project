################################# CICD - CODE PIPELINE #################################

#================= CodePipeline =================#
resource "aws_codepipeline" "codepipeline" {
  for_each = aws_codebuild_project.project
  name     = "${var.project.env}-${var.project.name}-${each.key}"
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = "${aws_s3_bucket.bucket_artifact[each.key].bucket}"
    type     = "S3"
  }

  depends_on = [aws_s3_bucket_versioning.bucket_artifact]

  #Source Stage (GitHub v2 via CodeStar Connections)
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["Source_Artifacts"]

      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.github.arn
        FullRepositoryId     = "${var.cicd_git.org}/${var.cicd_git.repos[each.key]}"
        BranchName           = "${var.cicd_git.branch}"
        OutputArtifactFormat = "CODE_ZIP"
        DetectChanges        = "true"
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
        ProjectName = each.value.name
      }
    }
  }

  # ECS deploy for API services 
  # stage {
  #     name = "Deploy"

  #     action {
  #       name            = "Deploy"
  #       category        = "Deploy"
  #       owner           = "AWS"
  #       provider        = "ECS"
  #       input_artifacts = ["Build_Artifacts"]
  #       version         = "1"

  #       configuration = {
  #         ClusterName = "${var.cicd_auth_env.ecs_cluster_name}"
  #         ServiceName = "${var.cicd_auth_env.service}"
  #         FileName    = "artifact.json"
  #       }
  #     }
  # }
}

#================= GitHub v2 connection =================#
resource "aws_codestarconnections_connection" "github" {
  name          = "${var.project.env}-${var.project.name}-github"
  provider_type = "GitHub"

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-github"
    Module = "${path.module}"
  })
}
