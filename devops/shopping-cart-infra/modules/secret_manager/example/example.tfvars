#################### EXAMPLE.TFVARS ########################

#============== Secret Manager =============#
secrets = {
  api_gateway = {
    secret_name = "api-gateway"
  },

  database = {
    secret_name       = "mysql-credentials"
    use_initial_value = false
    secret_data = {
      DATABASE = "MYSQL_DATABASE"
      USERNAME = "admin"
      PORT     = 3306
    }
  }
}