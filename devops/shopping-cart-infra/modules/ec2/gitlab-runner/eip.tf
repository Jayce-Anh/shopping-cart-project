######################## GITLAB RUNNER EIP #########################

resource "aws_eip" "runner" {
  domain = "vpc"
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-gitlab-runner-eip"
  })
}

resource "aws_eip_association" "runner" {
  instance_id   = aws_instance.runner.id
  allocation_id = aws_eip.runner.id
}
