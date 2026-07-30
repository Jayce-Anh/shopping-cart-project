############################ CODE PIPELINE/BUILD/DEPLOY - OUTPUT ############################

#-------------------- Code Build ----------------#
output "project_name" {
  value = aws_codebuild_project.codebuild.name
}

output "project_arn" {
  value = aws_codebuild_project.codebuild.arn
}

output "codebuild_role_arn" {
  value = aws_iam_role.codebuild_role.arn
}

#-------------------- Code Deploy (optional) ----------------#
output "codedeploy_app_name" {
  value = var.enable_codedeploy ? aws_codedeploy_app.codedeploy_app[0].name : null
}

output "codedeploy_deployment_group_name" {
  value = var.enable_codedeploy ? aws_codedeploy_deployment_group.codedeploy_deployment_group[0].deployment_group_name : null
}

output "codedeploy_role_arn" {
  value = var.enable_codedeploy ? aws_iam_role.codedeploy_role[0].arn : null
}

#-------------------- Code Pipeline ----------------#
output "codepipeline_name" {
  value = aws_codepipeline.codepipeline.name
}

output "codepipeline_arn" {
  value = aws_codepipeline.codepipeline.arn
}

output "bucket_artifact_name" {
  value = aws_s3_bucket.bucket_artifact.bucket
}
