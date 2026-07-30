################################# S3 BUCKET #################################
#Create S3 Bucket
resource "aws_s3_bucket" "s3" {
  bucket        = "${var.project.env}-${var.project.name}-${var.cf_service_name}-s3cf"
  force_destroy = var.cf_s3_force_del

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.cf_service_name}"
  })
}

# resource "aws_s3_bucket_acl" "s3" {
#   bucket = aws_s3_bucket.s3.id
#   acl    = var.bucket_acl
# }

resource "aws_s3_bucket_versioning" "s3" {
  bucket = aws_s3_bucket.s3.id

  versioning_configuration {
    status     = lookup(var.cf_versioning, "status", lookup(var.cf_versioning, "enabled", "Enabled"))
    mfa_delete = lookup(var.cf_versioning, "mfa_delete", null)
  }
}

#S3 Ownership Controls
resource "aws_s3_bucket_ownership_controls" "s3" {
  count = var.cf_ownership_config != null ? 1 : 0

  bucket = aws_s3_bucket.s3.id

  rule {
    object_ownership = lookup(var.cf_ownership_config, "object_ownership", "BucketOwnerPreferred")
  }
}


