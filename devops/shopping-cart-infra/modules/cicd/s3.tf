#========================= S3 Bucket ==========================#
resource "aws_s3_bucket" "bucket_artifact" {
  for_each      = local.cicd_services
  bucket        = "${var.project.env}-${var.project.name}-${each.key}-cicd-artifact"
  force_destroy = true

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${each.key}-cicd-artifact"
    Env  = "${var.project.env}"
    Module = "${path.module}"
  })
}

resource "aws_s3_bucket_versioning" "bucket_artifact" {
  for_each = aws_s3_bucket.bucket_artifact
  bucket   = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_artifact" {
  for_each                = aws_s3_bucket.bucket_artifact
  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
