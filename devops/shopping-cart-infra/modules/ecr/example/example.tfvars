#################### EXAMPLE.TFVARS ########################

#============== ECR ==============#
ecr_services = {
  catalog = {
    name             = "catalog"
    keep_nums_images = 10
    force_del        = true
  }
  inventory = {
    name             = "inventory"
    keep_nums_images = 10
    force_del        = true
  }
  order = {
    name             = "order"
    keep_nums_images = 10
    force_del        = true
  }
  web-ui = {
    name             = "web-ui"
    keep_nums_images = 10
    force_del        = true
  }
}
