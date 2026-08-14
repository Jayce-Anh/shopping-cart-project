################################# S3 BUCKET #################################
#Create S3 Bucket
resource "aws_s3_bucket" "s3" {
  bucket        = "${var.project.env}-${var.project.name}-cloudfront"
  force_destroy = true

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-cloudfront"
  })
}

resource "aws_s3_bucket_versioning" "s3" {
  bucket = aws_s3_bucket.s3.id

  versioning_configuration {
    status     = "Enabled"
    mfa_delete = null
  }
}

#S3 Ownership Controls
resource "aws_s3_bucket_ownership_controls" "s3" {
  bucket = aws_s3_bucket.s3.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


