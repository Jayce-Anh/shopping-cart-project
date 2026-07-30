####################### EC2 INSTANCE #######################

#============= EC2 Instance ==================#
resource "aws_instance" "ec2" {
  ami                    = var.ec2_ami_id != null ? var.ec2_ami_id : data.aws_ami.ubuntu-ami.id
  instance_type          = var.ec2_instance_type
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  subnet_id              = var.ec2_subnet_id
  key_name               = var.ec2_key_name
  root_block_device {
    delete_on_termination = var.ec2_delete_on_termination != null ? var.ec2_delete_on_termination : true
    iops                  = var.ec2_iops
    volume_size           = var.ec2_volume_size
    volume_type           = var.ec2_volume_type
    encrypted             = var.ec2_kms_key_arn != null ? true : false
    kms_key_id            = var.ec2_kms_key_arn
  }
  dynamic "instance_market_options" {
    for_each = var.ec2_capacity_type == "SPOT" ? [1] : []
    content {
      market_type = "spot"
      spot_options {
        max_price                      = var.ec2_spot_max_price
        spot_instance_type             = "one-time"
        instance_interruption_behavior = var.ec2_spot_instance_interruption_behavior
      }
    }
  }

  depends_on = [
    aws_security_group.ec2-sg
  ]

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.ec2_instance_name}"
  })

  user_data            = var.ec2_path_user_data != null ? file("${var.ec2_path_user_data}") : null
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  lifecycle {
    ignore_changes = [
      user_data
    ]
  }
}
