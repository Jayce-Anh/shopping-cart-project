#------------------- EIP -------------------#
resource "aws_eip" "eip" {
  count  = var.ec2_enabled_eip ? 1 : 0
  domain = "vpc"
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.ec2_instance_name}-eip"
  })
}

#EIP Association
resource "aws_eip_association" "eip_assoc" {
  count = var.ec2_enabled_eip ? 1 : 0

  instance_id   = aws_instance.ec2.id
  allocation_id = aws_eip.eip[0].id
}
