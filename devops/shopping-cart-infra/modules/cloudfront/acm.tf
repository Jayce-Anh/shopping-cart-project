################################# CLOUDFRONT ACM CERTIFICATE #################################

# CloudFront requires ACM certificates in us-east-1
# Domain must be a real FQDN and match distribution aliases
resource "aws_acm_certificate" "cloudfront" {
  domain_name       = "${var.project.env}-${var.project.name}.${var.project.domain}"
  validation_method = "DNS"
  region            = "us-east-1"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-cloudfront"
  })
}
