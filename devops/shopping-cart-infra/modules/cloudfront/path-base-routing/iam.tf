################################# IAM #################################

#====================== CloudFront S3 Bucket Policy =======================#
data "aws_iam_policy_document" "policy_doc" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cf_oai.iam_arn]
    }
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.s3.id
  policy = data.aws_iam_policy_document.policy_doc.json
}

#====================== S3 Full Access Policy =======================#
resource "aws_iam_policy" "full" {
  name        = format("%s-s3-full-access-policy", aws_s3_bucket.s3.id)
  description = format("%s-s3-full-access-policy", aws_s3_bucket.s3.id)
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:*"]
        Effect = "Allow"
        Resource = [
          format("arn:aws:s3:::%s", "${aws_s3_bucket.s3.id}"),
          format("arn:aws:s3:::%s/*", "${aws_s3_bucket.s3.id}"),
        ]
      },
    ]
  })
}

#====================== CloudFront Invalidation Policy =======================#
resource "aws_iam_policy" "invalidation" {
  name = format("%s-cloudfront-invalidation-policy", aws_cloudfront_distribution.cf_distribution.id)

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["cloudfront:CreateInvalidation"]
        Resource = [aws_cloudfront_distribution.cf_distribution.arn]
      },
    ]
  })
}
