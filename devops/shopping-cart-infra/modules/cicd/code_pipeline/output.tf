output "codepipeline_name" {
  value = aws_codepipeline.codepipeline.name
}

output "codepipeline_arn" {
  value = aws_codepipeline.codepipeline.arn
}

output "codedeploy_role_arn" {
  value = aws_iam_role.codedeploy_role.arn
}

output "codebuild_role_arn" {
  value = aws_iam_role.codebuild_role.arn
}

output "bucket_artifact_name" {
  value = aws_s3_bucket.bucket_artifact.bucket
}
