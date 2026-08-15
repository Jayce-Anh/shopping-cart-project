########################### TARGET GROUPS #####################################

#================== API services (path-based) ======================#
resource "aws_lb_target_group" "catalog" {
  name                 = "${var.project.env}-${var.project.name}-catalog"
  port                 = 4000
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.alb_vpc_id
  deregistration_delay = 60

  health_check {
    interval            = 30
    path                = "/api/products"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200-499"
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-catalog"
  })
}

resource "aws_lb_target_group" "inventory" {
  name                 = "${var.project.env}-${var.project.name}-inventory"
  port                 = 5000
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.alb_vpc_id
  deregistration_delay = 60

  health_check {
    interval            = 30
    path                = "/api/inventory"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200-499"
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-inventory"
  })
}

resource "aws_lb_target_group" "order" {
  name                 = "${var.project.env}-${var.project.name}-order"
  port                 = 6000
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.alb_vpc_id
  deregistration_delay = 60

  health_check {
    interval            = 30
    path                = "/api/orders"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200-499"
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-order"
  })
}

#================== Platform services (host-based HTTPS) ======================#
resource "aws_lb_target_group" "argocd" {
  name                 = "${var.project.env}-${var.project.name}-argocd"
  port                 = 443
  protocol             = "HTTPS"
  target_type          = "ip"
  vpc_id               = var.alb_vpc_id
  deregistration_delay = 60

  health_check {
    interval            = 30
    path                = "/healthz"
    port                = "traffic-port"
    protocol            = "HTTPS"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200-499"
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-argocd"
  })
}

resource "aws_lb_target_group" "grafana" {
  name                 = "${var.project.env}-${var.project.name}-grafana"
  port                 = 8090
  protocol             = "HTTPS"
  target_type          = "ip"
  vpc_id               = var.alb_vpc_id
  deregistration_delay = 60

  health_check {
    interval            = 30
    path                = "/api/health"
    port                = "traffic-port"
    protocol            = "HTTPS"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200-499"
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-grafana"
  })
}

resource "aws_lb_target_group" "kibana" {
  name                 = "${var.project.env}-${var.project.name}-kibana"
  port                 = 5601
  protocol             = "HTTPS"
  target_type          = "ip"
  vpc_id               = var.alb_vpc_id
  deregistration_delay = 60

  health_check {
    interval            = 30
    path                = "/login"
    port                = "traffic-port"
    protocol            = "HTTPS"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200-499"
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-kibana"
  })
}
