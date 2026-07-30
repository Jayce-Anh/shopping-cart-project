######################## ALB ########################
output "lb_arn" {
  value = aws_lb.lb.arn
}

output "lb_sg_id" {
  value = aws_security_group.sg_lb.id
}

output "lb_listener_http_arn" {
  value = aws_lb_listener.lb_listener_http.arn
}

output "lb_listener_https_arn" {
  value = aws_lb_listener.lb_listener_https.arn
}
