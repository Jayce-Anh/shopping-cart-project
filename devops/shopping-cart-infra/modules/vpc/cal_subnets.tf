################################# LOCALS #################################

#====================== Multiple subnets per AZ =======================#

locals {
  # Calculate total public subnets across all AZs
  total_public_subnets = sum([for az_config in var.subnet_az : az_config.public_subnet_count])

  public_subnets = merge([
    for az_name, az_config in var.subnet_az : {
      for idx in range(az_config.public_subnet_count) :
      "${az_name}-public-${idx}" => {
        az           = az_name
        az_index     = az_config.az_index
        subnet_index = idx
        # Calculate sequential CIDR index
        cidr_index = az_config.az_index * az_config.public_subnet_count + idx
      }
    }
  ]...)

  private_subnets = merge([
    for az_name, az_config in var.subnet_az : {
      for idx in range(az_config.private_subnet_count) :
      "${az_name}-private-${idx}" => {
        az           = az_name
        az_index     = az_config.az_index
        subnet_index = idx
        # Calculate sequential CIDR index (offset by total public subnets)
        cidr_index = local.total_public_subnets + (az_config.az_index * az_config.private_subnet_count) + idx
      }
    }
  ]...)
}