#################### EXAMPLE.TFVARS ########################

subnet_az = {
  "ap-southeast-1a" = {
    az_index             = 0
    public_subnet_count  = 2 # 2 public subnets per AZ
    private_subnet_count = 2 # 2 private subnets per AZ
  }
  "ap-southeast-1b" = {
    az_index             = 1
    public_subnet_count  = 2
    private_subnet_count = 2
  }
}