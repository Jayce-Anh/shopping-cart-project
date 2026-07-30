####################### AUTO SCALING GROUP #######################

#================== Launch Template ==================#
resource "aws_launch_template" "launch_template" {
  name_prefix   = "${var.project.env}-${var.project.name}-${var.asg_instance_name}-"
  image_id      = var.asg_ami_id != null ? var.asg_ami_id : data.aws_ami.ubuntu-ami.id
  instance_type = var.asg_instance_type
  key_name      = var.asg_key_name

  vpc_security_group_ids = [aws_security_group.asg_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.asg_profile.name
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      delete_on_termination = true
      volume_size           = var.asg_volume_size
      volume_type           = var.asg_volume_type
      iops                  = var.asg_iops
      encrypted             = var.asg_kms_key_arn != null ? true : false
      kms_key_id            = var.asg_kms_key_arn
    }
  }

  user_data = var.asg_path_user_data != null ? base64encode(file("${var.asg_path_user_data}")) : null

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, {
      Name = "${var.project.env}-${var.project.name}-${var.asg_instance_name}"
    })
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(var.tags, {
      Name = "${var.project.env}-${var.project.name}-${var.asg_instance_name}-volume"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

#================== Auto Scaling Group ==================#
resource "aws_autoscaling_group" "asg" {
  name                      = "${var.project.env}-${var.project.name}-${var.asg_instance_name}-asg"
  vpc_zone_identifier       = var.asg_subnet_ids
  desired_capacity          = var.asg_desired_capacity
  max_size                  = var.asg_max_size
  min_size                  = var.asg_min_size
  health_check_type         = var.asg_health_check_type
  health_check_grace_period = var.asg_health_check_grace_period
  force_delete              = var.asg_force_del
  termination_policies      = var.asg_termination_policies

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }

  target_group_arns         = var.asg_target_group_arns
  wait_for_capacity_timeout = var.asg_wait_for_capacity_timeout

  tag {
    key                 = "Name"
    value               = "${var.project.env}-${var.project.name}-${var.asg_instance_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.project.env
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project.name
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "Terraform"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}
