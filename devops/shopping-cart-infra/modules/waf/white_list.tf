resource "aws_wafv2_ip_set" "fe_white_list" {
  provider           = aws.east
  name               = "${var.project.env}-${var.project.name}-white-list-to-frontend"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.fe_white_list

  tags = {
    Name = "${var.project.env}-${var.project.name}-white-list-to-frontend"
  }
  lifecycle {
    ignore_changes = [addresses]
  }
}