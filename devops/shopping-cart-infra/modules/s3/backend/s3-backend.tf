##################### S3 BACKEND STATE #####################
resource "aws_s3_bucket" "backend_state" {
  bucket = "${var.project.env}-${var.project.name}-tf-state"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "backend_state" {
  bucket = aws_s3_bucket.backend_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backend_state" {
  bucket = aws_s3_bucket.backend_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_public_access_block" "backend_state" {
  bucket = aws_s3_bucket.backend_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}