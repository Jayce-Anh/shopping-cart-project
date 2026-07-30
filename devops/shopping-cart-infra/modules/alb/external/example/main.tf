module "alb" {
  source                 = "./modules/alb/external"
  project                = local.project
  tags                   = local.tags
  lb_name                = "ex-alb"
  vpc_id                 = local.network.vpc_id
  dns_cert_arn           = module.acm_alb.cert_arn
  subnet_ids             = local.network.public_subnet_ids
  source_ingress_sg_cidr = ["0.0.0.0/0"]

  target_groups = {
    be = {
      name              = "tg-1"
      service_port      = 5000
      health_check_path = "/health"
      priority          = 1
      host_header       = "be-ecs.jayce-lab.work"
      target_type       = "ip"
      ec2_id            = null #use ECS service instead of EC2 instance
      #ec2_id           = module.ec2.ec2_id
    }
  }
}