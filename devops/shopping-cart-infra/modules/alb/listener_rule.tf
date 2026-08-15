############################### EXTERNAL ALB LISTENER RULE ###############################

#================== Listener rules ======================#
# HTTPS
resource "aws_lb_listener_rule" "https_catalog" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalog.arn
  }

  condition {
    path_pattern {
      values = ["/api/products", "/api/products/*"]
    }
  }
}

resource "aws_lb_listener_rule" "https_inventory" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.inventory.arn
  }

  condition {
    path_pattern {
      values = ["/api/inventory", "/api/inventory/*"]
    }
  }
}

resource "aws_lb_listener_rule" "https_order" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.order.arn
  }

  condition {
    path_pattern {
      values = ["/api/orders", "/api/orders/*"]
    }
  }
}

resource "aws_lb_listener_rule" "https_argocd" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 40

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.argocd.arn
  }

  condition {
    host_header {
      values = ["argocd.${var.project.env}-${var.project.name}.${var.project.domain}"] # argocd.lab-shopping-cart.jayce-lab.works
    }
  }
}

resource "aws_lb_listener_rule" "https_grafana" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 50

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }

  condition {
    host_header {
      values = ["grafana.${var.project.env}-${var.project.name}.${var.project.domain}"] # grafana.lab-shopping-cart.jayce-lab.works
    }
  }
}

resource "aws_lb_listener_rule" "https_kibana" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 60

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kibana.arn
  }

  condition {
    host_header {
      values = ["kibana.${var.project.env}-${var.project.name}.${var.project.domain}"] # kibana.lab-shopping-cart.jayce-lab.works
    }
  }
}

# HTTP
resource "aws_lb_listener_rule" "http_catalog" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalog.arn
  }

  condition {
    path_pattern {
      values = ["/api/products", "/api/products/*"]
    }
  }
}

resource "aws_lb_listener_rule" "http_inventory" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.inventory.arn
  }

  condition {
    path_pattern {
      values = ["/api/inventory", "/api/inventory/*"]
    }
  }
}

resource "aws_lb_listener_rule" "http_order" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.order.arn
  }

  condition {
    path_pattern {
      values = ["/api/orders", "/api/orders/*"]
    }
  }
}

resource "aws_lb_listener_rule" "http_argocd_redirect" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 40

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
      values = ["argocd.${var.project.env}-${var.project.name}.${var.project.domain}"] # argocd.lab-shopping-cart.jayce-lab.works
    }
  }
}

resource "aws_lb_listener_rule" "http_grafana_redirect" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 50

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
      values = ["grafana.${var.project.env}-${var.project.name}.${var.project.domain}"] # grafana.lab-shopping-cart.jayce-lab.works
    }
  }
}

resource "aws_lb_listener_rule" "http_kibana_redirect" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 60

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
      values = ["kibana.${var.project.env}-${var.project.name}.${var.project.domain}"] # kibana.lab-shopping-cart.jayce-lab.works
    }
  }
}