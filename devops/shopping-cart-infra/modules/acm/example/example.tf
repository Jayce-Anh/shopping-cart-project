module "acm_alb" {
  source = ".."

  project    = local.project
  tags       = local.tags
  acm_region = local.project.region
  acm_certs = {
    alb = {
      domain = "*.jayce-lab.work"
    }
  }
}

module "acm_cf" {
  source = ".."

  project    = local.project
  tags       = local.tags
  acm_region = "us-east-1"
  acm_certs = {
    cf = {
      domain = "*.jayce-lab.work"
    }
  }
}
