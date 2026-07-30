######################## EXAMPLE - PATH-BASE ROUTING #########################

# --- Option A: ALB as API backend ---
module "cloudfront_alb" {
  source             = "../modules/cloudfront/path-base-routing"
  project            = local.project
  tags               = local.tags
  service_name       = "fe"
  cf_cert_arn        = module.acm.cert_arn
  cloudfront_aliases = ["app.myshop.com"]
  alb_dns_name       = module.alb.alb_dns_name # routes /api/* → ALB → ECS
  custom_error_response = {
    "403" = {
      error_code         = 403
      response_code      = 200
      response_page_path = "/index.html"
    }
  }
}

# --- Option B: API Gateway as API backend ---
module "cloudfront_apigw" {
  source             = "../modules/cloudfront/path-base-routing"
  project            = local.project
  tags               = local.tags
  service_name       = "fe"
  cf_cert_arn        = module.acm.cert_arn
  cloudfront_aliases = ["app.myshop.com"]
  api_gateway_domain = "abc123.execute-api.ap-southeast-1.amazonaws.com" # routes /api/* → API GW → Lambda
  api_gateway_stage  = "/prod"
  custom_error_response = {
    "403" = {
      error_code         = 403
      response_code      = 200
      response_page_path = "/index.html"
    }
  }
}
