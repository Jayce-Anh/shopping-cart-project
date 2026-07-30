##################################### DocumentDB #####################################

#---------------------------------Parameter Group---------------------------------
resource "aws_docdb_cluster_parameter_group" "docdb_parameter_group" {
  name   = "${var.project.env}-${var.project.name}-${var.docdb_name}-cluster-pg"
  family = var.docdb_family

  dynamic "parameter" {
    for_each = var.docdb_parameters
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.docdb_name}-cluster-pg"
  })
}

#---------------------------------Subnet Group---------------------------------
resource "aws_docdb_subnet_group" "docdb_subnet_group" {
  name       = "${var.project.env}-${var.project.name}-${var.docdb_name}"
  subnet_ids = var.network.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.docdb_name}-subnet-group"
  })
}

#---------------------------------DocumentDB Cluster---------------------------------
resource "aws_docdb_cluster" "docdb_cluster" {
  cluster_identifier = "${var.project.env}-${var.project.name}-${var.docdb_name}"
  engine             = "docdb"
  engine_version     = var.docdb_engine_version
  master_username    = var.docdb_username
  master_password    = var.docdb_password
  port               = var.docdb_port

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.docdb_parameter_group.name
  db_subnet_group_name            = aws_docdb_subnet_group.docdb_subnet_group.name
  vpc_security_group_ids          = [aws_security_group.sg_docdb.id]

  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project.env}-${var.project.name}-${var.docdb_name}-final-snapshot"

  deletion_protection = var.deletion_protection
  apply_immediately   = var.apply_immediately

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.docdb_name}-cluster"
  })
}

#---------------------------------DocumentDB Instances---------------------------------
resource "aws_docdb_cluster_instance" "docdb_instances" {
  count              = var.instance_count
  identifier         = "${var.project.env}-${var.project.name}-${var.docdb_name}-${count.index + 1}"
  cluster_identifier = aws_docdb_cluster.docdb_cluster.id
  instance_class     = var.instance_class

  ca_cert_identifier = var.ca_cert_identifier

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.docdb_name}-instance-${count.index + 1}"
  })
} 