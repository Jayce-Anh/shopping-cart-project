########################### RDS SECRET ###########################

#================ Random Password =================#
resource "random_password" "rds" {
  length           = 16
  special          = true
  override_special = "_"
}

#================= MySQL Credentials =================#
resource "aws_secretsmanager_secret" "mysql" {
  name                    = "${var.project.env}-${var.project.name}-rds-credentials"
  recovery_window_in_days = 0
  kms_key_id              = var.rds_kms_key
  description             = "RDS credentials"

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-rds-credentials"
  })
}


#================ Secret Version =================#
resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = aws_secretsmanager_secret.mysql.id
  secret_string = jsonencode({
    DATABASE_USERNAME = "${aws_db_instance.db.username}"
    DATABASE_PASSWORD = "${random_password.rds.result}"
    DATABASE_HOST     = "${aws_db_instance.db.address}"
    DATABASE_PORT     = "${aws_db_instance.db.port}"
  })
}
