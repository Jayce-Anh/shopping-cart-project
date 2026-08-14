###################################### GITLAB RUNNER EC2 ##############################################

resource "aws_instance" "runner" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3a.medium"
  vpc_security_group_ids = [aws_security_group.runner.id]
  subnet_id              = var.subnet_id
  key_name               = "lab-jayce"

  root_block_device {
    delete_on_termination = true
    iops                  = 3000
    volume_size           = 40
    volume_type           = "gp3"
    encrypted             = true
    kms_key_id            = var.runner_kms_key
  }

  user_data                   = file("${path.module}/user_data.sh")
  user_data_replace_on_change = true
  iam_instance_profile        = aws_iam_instance_profile.runner.name

  depends_on = [aws_security_group.runner]

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-gitlab-runner"
  })

  lifecycle {
    ignore_changes = [user_data]
  }
}
