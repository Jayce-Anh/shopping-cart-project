################################# VPC #################################
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.vpc_name}"
  })
}

#====================== Public Subnets =======================#
resource "aws_subnet" "public" {
  for_each                = local.public_subnets
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  cidr_block              = cidrsubnet(var.cidr_block, 8, each.value.cidr_index)
  depends_on              = [aws_internet_gateway.igw]
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.vpc_name}-public-${each.value.az}-${each.value.subnet_index}"
    Type = "public"
    AZ   = each.value.az
  })
}

#====================== Private Subnets =======================#
resource "aws_subnet" "private" {
  for_each                = local.private_subnets
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = each.value.az
  map_public_ip_on_launch = false
  cidr_block              = cidrsubnet(var.cidr_block, 8, each.value.cidr_index)
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.vpc_name}-private-${each.value.az}-${each.value.subnet_index}"
    Type = "private"
    AZ   = each.value.az
  })
}

#====================== Internet Gateway =======================#
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.vpc_name}-igw"
  })
}

#====================== Elastic IP =======================#
# Create EIP for NAT 
resource "aws_eip" "nat" {
  domain = "vpc"

  lifecycle {
    # prevent_destroy = true 
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.vpc_name}-nat-eip"
  })
}

#====================== NAT Gateway =======================#
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[element(keys(aws_subnet.public), 0)].id
  depends_on    = [aws_internet_gateway.igw]
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.vpc_name}-natgw"
  })
}

#====================== Public Route Table =======================#
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.vpc_name}-public-rtb"
  })
}

#====================== Private Route Table =======================#
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.vpc_name}-private-rtb"
  })
}

#====================== Public Route =======================#
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

#====================== Private Route =======================#
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
  # lifecycle {
  #   ignore_changes = [gateway_id, nat_gateway_id]
  # }
}

#====================== Public Route to Public Route Table for Public Subnets =======================#
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

#====================== Private Route to Private Route Table for Private Subnets =======================#
resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private.id
}

