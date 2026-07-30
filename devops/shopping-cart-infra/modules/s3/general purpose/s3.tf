################# S3 - GENERAL PURPOSE #################
resource "aws_s3_bucket" "general_purpose" {
  bucket = "${var.project.account_ids}-${var.project.name}-${var.bucket_name}"
}

resource "aws_s3_bucket_versioning" "general_purpose" {
  bucket = aws_s3_bucket.general_purpose.id

  versioning_configuration {
    status     = var.versioning.status
    mfa_delete = var.versioning.mfa_delete
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "general_purpose" {
  bucket = aws_s3_bucket.general_purpose.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_public_access_block" "general_purpose" {
  bucket = aws_s3_bucket.general_purpose.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}