################################### CLOUDFRONT - PATH-BASE ROUTING ###################################

#====================== Origin Access Identity =======================#
resource "aws_cloudfront_origin_access_identity" "cf_oai" {
  comment = "${var.project.env}-${var.project.name}"

  lifecycle {
    create_before_destroy = true
  }
}

#====================== CloudFront Distribution ============================#
resource "aws_cloudfront_distribution" "cf_distribution" {

  # Origin 1: S3 (static UI)
  origin {
    domain_name = aws_s3_bucket.s3.bucket_regional_domain_name
    origin_id   = "${var.project.env}-${var.project.name}-s3"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cf_oai.cloudfront_access_identity_path
    }
  }

  #  Origin 2a: ALB
  # CloudFront does not allow custom_header name "Host" — use HTTP to ALB instead.
  origin {
    domain_name = var.cf_alb_dns_name
    origin_id   = "${var.project.env}-${var.project.name}-alb"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Origin 2b: API Gateway 
  # origin {
  #   domain_name = var.cf_api_gw_origin_domain_name
  #   origin_id   = "${var.project.env}-${var.project.name}-apigw"
  #   origin_path = var.cf_api_gw_origin_path
  #   custom_origin_config {
  #     http_port              = 80
  #     https_port             = 443
  #     origin_protocol_policy = "https-only"
  #     origin_ssl_protocols   = ["TLSv1.2"]
  #   }
  # }

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

  # Default behavior: S3 static UI
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${var.project.env}-${var.project.name}-s3"
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

  # Ordered behavior: /api/* → ALB
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "${var.project.env}-${var.project.name}-alb"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cloudfront.arn
    ssl_support_method  = "sni-only"
  }

  # SPA fallback (same create result as old tfvars)
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  depends_on = [aws_s3_bucket.s3]

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-cloudfront"
  })
}
