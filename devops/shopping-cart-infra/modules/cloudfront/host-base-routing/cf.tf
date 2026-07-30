################################### CLOUDFRONT - HOST-BASE ROUTING ###################################

#================ Origin Access Identity ===============#
resource "aws_cloudfront_origin_access_identity" "cf_oai" {
  comment = "${var.project.env}-${var.project.name}-${var.cf_service_name}"
  lifecycle {
    create_before_destroy = true
  }
}

#============= CloudFront Distribution ===============#
resource "aws_cloudfront_distribution" "cf_distribution" {
  origin {
    domain_name = aws_s3_bucket.s3.bucket_regional_domain_name
    origin_id   = "${var.project.env}-${var.project.name}-${var.cf_service_name}"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cf_oai.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  comment             = "${var.project.env}-${var.project.name}-${var.cf_service_name}"
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_All"
  aliases             = [var.cf_cert_domain]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${var.project.env}-${var.project.name}-${var.cf_service_name}"
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
    acm_certificate_arn = var.cf_cert_arn
    ssl_support_method  = "sni-only"
  }

  dynamic "custom_error_response" {
    for_each = var.cf_custom_error_response
    content {
      error_code            = custom_error_response.value["error_code"]
      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
    }
  }

  depends_on = [aws_s3_bucket.s3]

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.cf_service_name}"
  })
}
