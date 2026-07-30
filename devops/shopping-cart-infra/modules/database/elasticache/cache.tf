#################################### ELASTICACHE ####################################

#=============== Elasticache subnet group ===============#
resource "aws_elasticache_subnet_group" "subnet_group" {
  name       = "${var.project.env}-${var.project.name}-${var.cache_name}"
  subnet_ids = var.subnet_ids
}

#=============== Elasticache parameter group ===============#
resource "aws_elasticache_parameter_group" "parameter_group" {
  name   = "${var.project.env}-${var.project.name}-${var.cache_name}"
  family = var.cache_family

  dynamic "parameter" {
    for_each = var.cache_parameters
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.cache_name}"
  })
}

#=============== Elasticache replication group ===============#
resource "aws_elasticache_replication_group" "cache" {
  replication_group_id = "${var.project.env}-${var.project.name}-${var.cache_name}"
  description          = "${var.project.env} ${var.project.name} ${var.cache_name}"
  engine               = var.cache_engine
  engine_version       = var.cache_version
  node_type            = var.cache_node_type
  num_cache_clusters   = var.cache_num_cache_clusters
  port                 = var.cache_port

  subnet_group_name    = aws_elasticache_subnet_group.subnet_group.name
  parameter_group_name = aws_elasticache_parameter_group.parameter_group.name
  security_group_ids   = [aws_security_group.sg.id]

  at_rest_encryption_enabled = true
  kms_key_id                 = var.kms_key_arn

  auto_minor_version_upgrade = false
  apply_immediately          = true

  snapshot_window          = var.snapshot_window
  snapshot_retention_limit = var.cache_snapshot_retention_limit
  maintenance_window       = var.maintenance_window

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.cache_name}"
  })
}
