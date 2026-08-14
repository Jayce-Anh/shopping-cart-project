#================ Read Replica =================#
resource "aws_db_instance" "read_replica" {
  identifier             = "${var.project.env}-${var.project.name}-read-replica"
  replicate_source_db    = aws_db_instance.db.arn
  instance_class         = aws_db_instance.db.instance_class
  publicly_accessible    = aws_db_instance.db.publicly_accessible
  skip_final_snapshot    = aws_db_instance.db.skip_final_snapshot
  vpc_security_group_ids = [aws_security_group.sg_db.id]
  storage_encrypted      = aws_db_instance.db.storage_encrypted

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-read-replica"
  })
}
