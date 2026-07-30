module "valkey" {
  source                            = "./valkey"
  project                           = var.project
  tags                              = var.tags
  vpc_id                            = var.vpc_id
  subnet_ids                        = var.subnet_ids
  valkey_name                       = var.valkey_name
  valkey_engine_version             = var.valkey_engine_version
  valkey_port                       = var.valkey_port
  valkey_num_cache_clusters         = var.valkey_num_cache_clusters
  valkey_node_type                  = var.valkey_node_type
  valkey_snapshot_retention_limit   = var.valkey_snapshot_retention_limit
  valkey_family                     = var.valkey_family
  allowed_cidr_blocks_access_valkey = [module.eks.node_group_sg_ids]
  allowed_sg_ids_access_valkey      = var.allowed_sg_ids
  valkey_parameters                 = var.valkey_parameters
}
