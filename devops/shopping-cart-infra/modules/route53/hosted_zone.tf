############################# ROUTE53 - HOSTED ZONE ##############################

resource "aws_route53_zone" "hosted_zone" {
  name          = var.project.domain
  comment       = "Hosted zone for ${var.project.name}"
  force_destroy = true

  tags = {
    Name   = "${var.project.name}"
    Module = "${path.module}"
    ManagedBy = "Terraform"
    Owner = "Jayce"
  }
}
