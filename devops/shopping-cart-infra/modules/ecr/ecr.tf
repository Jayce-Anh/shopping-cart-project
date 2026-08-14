########################### ECR ##############################

#================= ECR Repository ================#
resource "aws_ecr_repository" "ecr" {
  for_each             = toset(["catalog", "inventory", "order"])
  name                 = "${var.project.env}-${var.project.name}-${each.key}"
  force_delete         = true
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.ecr_kms_key
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${each.key}"
  })
}

#================= ECR Lifecycle Policy ================#
resource "aws_ecr_lifecycle_policy" "ecr" {
  for_each   = aws_ecr_repository.ecr
  repository = aws_ecr_repository.ecr[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 3 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 3
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
