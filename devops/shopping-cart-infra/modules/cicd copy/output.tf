############################ CODE PIPELINE/BUILD/DEPLOY - OUTPUT ############################

#=================== Code Build ==================#
output "project_name" {
  value = { for k, v in aws_codebuild_project.project : k => v.name }
}

output "project_arn" {
  value = { for k, v in aws_codebuild_project.project : k => v.arn }
}

#=================== Code Pipeline ==================#
output "codepipeline_name" {
  value = { for k, v in aws_codepipeline.codepipeline : k => v.name }
}

output "codepipeline_arn" {
  value = { for k, v in aws_codepipeline.codepipeline : k => v.arn }
}

output "bucket_artifact_name" {
  value = { for k, v in aws_s3_bucket.bucket_artifact : k => v.bucket }
}

output "github_connection_arn" {
  value = aws_codestarconnections_connection.github.arn
}

output "github_connection_status" {
  value = aws_codestarconnections_connection.github.connection_status
}

#=================== Code Deploy ==================#
# output "codedeploy_app_name" {
#   value = aws_codedeploy_app.codedeploy_app.name
# }

# output "codedeploy_deployment_group_name" {
#   value = aws_codedeploy_deployment_group.codedeploy_deployment_group.deployment_group_name
# }

# output "codedeploy_role_arn" {
#   value = aws_iam_role.codedeploy_role.arn
# }


