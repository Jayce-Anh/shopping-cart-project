########################### EXTERNAL APPLICATION LOAD BALANCER ###########################

#================= ALB =================#
resource "aws_lb" "lb" {
  name               = "${var.project.env}-${var.project.name}-external"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_lb.id]
  subnets            = var.alb_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-external"
  })
}

#================= Listeners =================#
# HTTPS
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.alb_dns_cert

  default_action {
    type = "fixed-response"
    fixed_response {
      status_code  = "404"
      content_type = "text/plain"
      message_body = "Not Found"
    }
  }
}

# HTTP
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
