##################################### Example Usage #####################################

# Example usage of the DocumentDB module
module "docdb" {
  source = "./modules/database/docdb"

  project = {
    env  = "dev"
    name = "easyshop"
  }

  network = {
    vpc_id             = "vpc-xxxxxxxxx"
    private_subnet_ids = ["subnet-xxxxxxxxx", "subnet-yyyyyyyyy"]
  }

  # DocumentDB Configuration
  docdb_name           = "mongodb"
  docdb_family         = "docdb4.0"
  docdb_engine_version = "4.0.0"
  docdb_username       = "admin"
  docdb_password       = "your-secure-password" # Use AWS Secrets Manager in production
  docdb_port           = 27017

  # Instance Configuration
  instance_count = 2
  instance_class = "db.t3.medium"

  # Security group
  allowed_sg_ids_access_docdb = ["sg-xxxxxxxxx", "sg-yyyyyyyyy"]

  # Backup Configuration
  backup_retention_period      = 7
  preferred_backup_window      = "07:00-09:00"
  preferred_maintenance_window = "sun:04:00-sun:05:00"

  # Security Configuration
  storage_encrypted   = true
  deletion_protection = false
  skip_final_snapshot = true

  # DocumentDB Parameters
  docdb_parameters = {
    "tls"                   = "enabled"
    "ttl_monitor"           = "enabled"
    "audit_logs"            = "enabled"
    "profiler"              = "enabled"
    "profiler_threshold_ms" = "100"
  }

  tags = {
    Name = "${var.project.env}-${var.project.name}-${var.docdb_name}"
    env  = "${var.project.env}"
  }
}

