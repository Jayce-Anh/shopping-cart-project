################################### CLOUDFRONT - HOST-BASE ROUTING ###################################

#================ Origin Access Identity ===============#
resource "aws_cloudfront_origin_access_identity" "cf_oai" {
  comment = "${var.project.env}-${var.project.name}"
  lifecycle {
    create_before_destroy = true
  }
}

#============= CloudFront Distribution ===============#
resource "aws_cloudfront_distribution" "cf_distribution" {
  origin {
    domain_name = aws_s3_bucket.s3.bucket_regional_domain_name
    origin_id   = "${var.project.env}-${var.project.name}"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cf_oai.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  comment             = "${var.project.env}-${var.project.name}"
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_All"
  aliases             = ["${var.project.env}-${var.project.name}.${var.project.domain}"] # lab-shopping-cart.jayce-lab.works

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${var.project.env}-${var.project.name}"
    compress         = true
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 60 
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cloudfront.arn
    ssl_support_method  = "sni-only"
  }

  custom_error_response {
      error_code            = 404
      response_code         = 404
      response_page_path    = "/index.html"
      error_caching_min_ttl = 60
  }

  depends_on = [aws_s3_bucket.s3]

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}"
  })
}
