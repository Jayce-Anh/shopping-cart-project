################################# CLOUDFRONT ACM CERTIFICATE #################################

#================ CloudFront - Certificate =================#
resource "aws_acm_certificate" "cloudfront" {
  domain_name               = "${var.project.env}-${var.project.name}-cloudfront"
  validation_method         = "DNS"
  subject_alternative_names = null
  region                    = "us-east-1"
  
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-cloudfront"
  })
}