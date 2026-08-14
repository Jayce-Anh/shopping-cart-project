################################### VPC ########################################

#=============== VPC ================#
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}"
  })
}

#====================== Availability zones =======================#
locals {
  azs = ["ap-southeast-1b", "ap-southeast-1c"]
}

#====================== Subnets =======================#
# Public Subnets
resource "aws_subnet" "public-1" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = local.azs[0]
  map_public_ip_on_launch = true
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 1) # 10.0.1.0/24
  depends_on              = [aws_internet_gateway.igw]
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-public-${local.azs[0]}"
    AZ   = "${local.azs[0]}"
  })
}

resource "aws_subnet" "public-2" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = local.azs[1]
  map_public_ip_on_launch = true
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 2) # 10.0.2.0/24
  depends_on              = [aws_internet_gateway.igw]
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-public-${local.azs[1]}"
    AZ   = "${local.azs[1]}"
  })
}

# Private Subnets
resource "aws_subnet" "private-1" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = local.azs[0]
  map_public_ip_on_launch = false
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 3) # 10.0.3.0/24
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-private-${local.azs[0]}"
    AZ   = "${local.azs[0]}"
  })
}

resource "aws_subnet" "private-2" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = local.azs[1]
  map_public_ip_on_launch = false
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 4) # 10.0.4.0/24
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-private-${local.azs[1]}"
    AZ   = "${local.azs[1]}"
  })
}

#====================== Internet Gateway =======================#
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}"
  })
}

#====================== Elastic IP =======================#
# EIP for NAT 
resource "aws_eip" "nat" {
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-nat"
  })
}

#====================== NAT Gateway =======================#
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-1.id
  depends_on    = [aws_internet_gateway.igw]
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}"
  })
}

#============== Route Table ================#
# Public Route Table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-public"
  })
}

# Private Route Table
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-private"
  })
}

#================== Route Table Association ====================#
resource "aws_route_table_association" "public" {
  for_each = {
    public-1 = aws_subnet.public-1.id
    public-2 = aws_subnet.public-2.id
  }
  subnet_id      = each.value
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private" {
  for_each = {
    private-1 = aws_subnet.private-1.id
    private-2 = aws_subnet.private-2.id
  }
  subnet_id      = each.value
  route_table_id = aws_route_table.private-rt.id
}



