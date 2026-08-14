########################## VPC OUTPUT ##########################

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public-1.id, aws_subnet.public-2.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.private-1.id, aws_subnet.private-2.id]
}
