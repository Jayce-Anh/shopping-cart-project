#================ Read Replica =================#
resource "aws_db_instance" "read_replica" {
  count = var.read_replica_enable ? 1 : 0

  identifier             = "${var.project.env}-${var.project.name}-${var.rds_name}-replica"
  replicate_source_db    = aws_db_instance.db.arn
  instance_class         = coalesce(var.read_replica_class, var.rds_class)
  publicly_accessible    = false
  skip_final_snapshot    = var.read_replica_skip_final_snapshot
  vpc_security_group_ids = [aws_security_group.sg_db.id]

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.rds_name}-replica"
  })
}
