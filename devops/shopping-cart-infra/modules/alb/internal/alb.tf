############################ INTERNAL APPLICATION LOAD BALANCER ############################

#===================== Application Load Balancer =====================#
resource "aws_lb" "lb" {
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_lb.id]
  subnets            = var.subnet_ids
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-internal"
  })
}

#===================== Listener of Load Balancer =====================#
resource "aws_lb_listener" "lb_listener_https" {
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

  default_action {
    type = "fixed-response"
    fixed_response {
      status_code  = "404"
      content_type = "text/plain"
    }
  }
}
