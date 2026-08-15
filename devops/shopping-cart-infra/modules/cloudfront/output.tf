################################# OUTPUTS #################################

output "cf_distribution_domain_name" {
  value = aws_cloudfront_distribution.cf_distribution.domain_name
}

output "cf_distribution_hosted_zone_id" {
  value = aws_cloudfront_distribution.cf_distribution.hosted_zone_id
}

output "invalidation_policy_arn" {
  value = aws_iam_policy.invalidation.arn
}

output "distribution_id" {
  value = aws_cloudfront_distribution.cf_distribution.id
}

output "cfs3_bucket" {
  value = aws_s3_bucket.s3.bucket
}
