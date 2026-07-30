################################ ECS #######################################
module "ecs" {
  source           = "./modules/ecs-pro"
  project          = local.project
  tags             = local.project.tags
  vpc_id           = local.network.vpc_id
  lb_sg_id         = module.external_lb.lb_sg_id
  target_group_arn = module.external_lb.tg_arns[be]
  subnets          = local.network.private_subnet_id
  task_definitions = {
    "be" = {
      desired_count        = 1
      cpu                  = 1024 # 1 vCPU
      memory               = 2048 # 2 GB RAM
      container_port       = 3000
      host_port            = 3000
      health_check_path    = "/health"
      enable_load_balancer = true
      load_balancer = {
        target_group_port = 3000
        container_port    = 3000
      }
    }
  }
}