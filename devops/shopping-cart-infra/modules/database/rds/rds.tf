##################################### RDS #####################################

#================ Parameter Group =================#
resource "aws_db_parameter_group" "db_parameter_group" {
  name   = "${var.project.env}-${var.project.name}-rds"
  family = "mysql8.0"

  parameter {
    name         = "max_connections"
    value        = "200"
    apply_method = "pending-reboot"
  }
}

#================ Subnet Group =================#
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.project.env}-${var.project.name}-rds"
  subnet_ids = var.rds_subnet_ids
}

#================ RDS Instance =================#
resource "aws_db_instance" "db" {
  identifier            = "${var.project.env}-${var.project.name}"
  multi_az              = false
  allocated_storage     = 20
  max_allocated_storage = 40

  storage_type       = "gp3"
  iops               = null
  storage_throughput = null

  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = replace("${var.project.name}", "-", "_")
  username               = "admin"
  password               = random_password.rds.result
  port                   = 3306
  parameter_group_name   = aws_db_parameter_group.db_parameter_group.name
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.sg_db.id]

  storage_encrypted = true
  kms_key_id        = var.rds_kms_key

  performance_insights_enabled = false
  publicly_accessible          = false
  skip_final_snapshot          = true # if you want snapshot before deleteing set to false

  # apply_immediately = true
  # final_snapshot_identifier = "${var.project.env}-${var.project.name}-${var.rds_name}-final-snapshot"

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = false

  lifecycle {
    ignore_changes = [publicly_accessible, engine_version]
  }

  backup_retention_period = 7
  backup_window           = "02:00-03:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-rds"
  })
}


