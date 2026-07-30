########################### TARGET GROUPS #####################################

#================== Target Groups ======================#
resource "aws_lb_target_group" "tg" {
  for_each = var.alb_target_groups

  name                 = "${var.project.env}-${var.project.name}-${each.value.name}"
  port                 = each.value.service_port
  protocol             = each.value.protocol
  target_type          = each.value.target_type
  vpc_id               = var.alb_vpc_id
  deregistration_delay = "60"

  health_check {
    interval            = 30
    path                = each.value.health_check_path
    port                = "traffic-port"
    protocol            = coalesce(each.value.health_check_protocol, each.value.protocol)
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200-499"
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-tg-${each.value.name}"
  })
}

#================== Listener Rules: HTTPS ======================#
resource "aws_lb_listener_rule" "https_rule" {
  for_each = var.alb_enable_https_listener ? var.alb_target_groups : {}

  listener_arn = aws_lb_listener.lb_listener_https[0].arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.key].arn
  }

  dynamic "condition" {
    for_each = each.value.path_patterns != null ? [1] : []
    content {
      path_pattern {
        values = each.value.path_patterns
      }
    }
  }

  dynamic "condition" {
    for_each = each.value.host_header != null ? [1] : []
    content {
      host_header {
        values = [each.value.host_header]
      }
    }
  }
}

#================== Listener Rules: HTTP path-based (CloudFront → ALB /api/*) ======================#
resource "aws_lb_listener_rule" "http_rule" {
  for_each = {
    for k, v in var.alb_target_groups : k => v
    if v.path_patterns != null
  }

  listener_arn = aws_lb_listener.lb_listener_http.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.key].arn
  }

  condition {
    path_pattern {
      values = each.value.path_patterns
    }
  }
}

#================== Listener Rules: HTTP host-based → redirect to HTTPS ======================#
resource "aws_lb_listener_rule" "http_host_redirect" {
  for_each = var.alb_enable_https_listener ? {
    for k, v in var.alb_target_groups : k => v
    if v.host_header != null
  } : {}

  listener_arn = aws_lb_listener.lb_listener_http.arn
  priority     = each.value.priority

  action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = [each.value.host_header]
    }
  }
}

#================== Register target group target to instance ======================#
resource "aws_lb_target_group_attachment" "instance_target_group_attachment" {
  for_each = {
    for k, v in var.alb_target_groups : k => v
    if v.target_type == "instance" && v.ec2_id != null
  }

  target_group_arn = aws_lb_target_group.tg[each.key].arn
  target_id        = each.value.ec2_id
  port             = each.value.service_port
}




