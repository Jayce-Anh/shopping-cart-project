############################## ACM #############################

#================ ALB - Certificate =================#
resource "aws_acm_certificate" "alb" {
  domain_name       = "*.${var.project.env}-${var.project.name}.${var.project.domain}"
  validation_method = "DNS"
  region            = var.project.region

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-alb"
  })
}