################################### ENDPOINT ###################################

# ALB takes precedence if both ALB and API Gateway are set as internet endpoints.
# Use ALB         → set alb_dns_name
# Use API GATEWAY → set api_gw_domain (+ api_gateway_stage)
locals {
  use_alb   = var.cf_alb_dns_name != null
  use_apigw = var.cf_api_gw_domain != null && !local.use_alb

  # Origin ID targeted by the /api/* ordered cache behavior
  api_origin_id = local.use_alb ? "${var.project.env}-${var.project.name}-alb" : (
    "${var.project.env}-${var.project.name}-apigw"
  )

  # ALB   → forward all headers (Host header is fine)
  # APIGW → must NOT forward Host; only specific headers
  api_forward_headers = local.use_apigw ? [
    "Authorization",
    "Content-Type",
    "Accept",
    "Origin",
  ] : ["*"]
}
