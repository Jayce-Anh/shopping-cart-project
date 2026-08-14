######################## BASTION EIP #########################

resource "aws_eip" "bastion" {
  domain = "vpc"
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-bastion-eip"
  })
}

resource "aws_eip_association" "bastion" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion.id
}
