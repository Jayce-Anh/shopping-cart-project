########################### APPLICATION LOAD BALANCER ###########################
#---------------------Application Load Balancer---------------------#
resource "aws_lb" "lb" {
  name               = "${var.project.env}-${var.project.name}-${var.alb_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_lb.id]
  subnets            = var.alb_subnet_ids
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.alb_name}"
  })
}

#Listener of Load Balancer
resource "aws_lb_listener" "lb_listener_https" {
  count             = var.alb_enable_https_listener ? 1 : 0
  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.alb_dns_cert

  default_action {
    type = "fixed-response"
    fixed_response {
      status_code  = "404"
      content_type = "text/plain"
    }
  }
}

resource "aws_lb_listener" "lb_listener_http" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  # Redirect all unmatched HTTP traffic to HTTPS when the HTTPS listener is enabled.
  dynamic "default_action" {
    for_each = var.alb_enable_https_listener ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = var.alb_enable_https_listener ? [] : [1]
    content {
      type = "fixed-response"
      fixed_response {
        status_code  = "404"
        content_type = "text/plain"
      }
    }
  }
}

