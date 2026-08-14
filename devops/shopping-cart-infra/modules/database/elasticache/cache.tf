#################################### ELASTICACHE ####################################

#=============== Elasticache subnet group ===============#
resource "aws_elasticache_subnet_group" "subnet_group" {
  name       = "${var.project.env}-${var.project.name}-valkey"
  subnet_ids = var.cache_subnet_ids
}

#=============== Elasticache parameter group ===============#
resource "aws_elasticache_parameter_group" "parameter_group" {
  name   = "${var.project.env}-${var.project.name}-valkey"
  family = "valkey7"

  parameter {
    name  = "maxmemory-policy"
    value = "noeviction"
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-valkey"
  })
}

#=============== Elasticache replication group ===============#
resource "aws_elasticache_replication_group" "cache" {
  replication_group_id = "${var.project.env}-${var.project.name}-valkey"
  description          = "${var.project.env} ${var.project.name} valkey"
  engine               = "valkey"
  engine_version       = "7.2"
  node_type            = "cache.t3.micro"
  num_cache_clusters   = 2
  port                 = 6379

  subnet_group_name    = aws_elasticache_subnet_group.subnet_group.name
  parameter_group_name = aws_elasticache_parameter_group.parameter_group.name
  security_group_ids   = [aws_security_group.sg.id]

  at_rest_encryption_enabled = true
  kms_key_id                 = var.cache_kms_key

  auto_minor_version_upgrade = false
  apply_immediately          = true

  snapshot_window          = "00:30-01:30"
  snapshot_retention_limit = 7
  maintenance_window       = "sat:04:30-sat:05:30"

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-valkey"
  })
}
