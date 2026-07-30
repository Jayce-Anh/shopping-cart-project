############################ SECURITY GROUP ############################
resource "aws_security_group" "sg_lb" {
  name        = "${var.project.env}-${var.project.name}-${var.lb_name}-alb"
  description = "SG of ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    description = "Allow HTTP from internet"
    cidr_blocks = var.source_ingress_sg_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.lb_name}-alb"
  })
}

#===================== Application Load Balancer =====================#
resource "aws_lb" "lb" {
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_lb.id]
  subnets            = var.subnet_ids
  tags = {
    Name        = "${var.project.env}-${var.project.name}-${var.lb_name}-alb"
    Description = "Internal ALB of ${var.project.env}-${var.project.name}"
  }
}

#===================== Listener of Load Balancer =====================#
resource "aws_lb_listener" "lb_listener_https" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.dns_cert_arn

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
