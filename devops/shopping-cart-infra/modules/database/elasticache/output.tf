############################# ELASTICACHE OUTPUT #################################
output "cache_replication_group_id" {
  value = aws_elasticache_replication_group.cache.id
}

output "cache_primary_endpoint" {
  value = aws_elasticache_replication_group.cache.primary_endpoint_address
}

output "cache_reader_endpoint" {
  value = aws_elasticache_replication_group.cache.reader_endpoint_address
}
