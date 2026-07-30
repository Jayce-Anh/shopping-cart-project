########################### ECR ##############################
resource "aws_ecr_repository" "ecr" {
  for_each     = var.ecr_services
  name         = "${var.project.env}-${var.project.name}-${each.value.name}"
  force_delete = each.value.force_del

  encryption_configuration {
    encryption_type = var.kms_key_arn != null ? "KMS" : "AES256"
    kms_key         = var.kms_key_arn
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${each.value.name}"
  })
}

#================= Policy ================#
resource "aws_ecr_lifecycle_policy" "ecr" {
  for_each   = var.ecr_services
  repository = aws_ecr_repository.ecr[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${each.value.keep_nums_images} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = each.value.keep_nums_images
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
