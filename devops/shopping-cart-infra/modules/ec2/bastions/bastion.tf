###################################### BASTION EC2 ##############################################

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id              = var.subnet_id
  key_name               = "lab-jayce"

  root_block_device {
    delete_on_termination = true
    iops                  = 3000
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    kms_key_id            = var.bastion_kms_key
  }

  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type             = "one-time"
      instance_interruption_behavior = "terminate"
    }
  }

  user_data                   = file("${path.module}/user_data.sh")
  user_data_replace_on_change = true
  iam_instance_profile        = aws_iam_instance_profile.bastion.name

  depends_on = [aws_security_group.bastion]

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-bastion"
  })

  lifecycle {
    ignore_changes = [user_data]
  }
}
