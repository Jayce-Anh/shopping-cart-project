##################### DYNAMODB TABLE #####################

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project.env}-${var.project.name}-${var.table_name}"
  billing_mode = var.billing_mode
  hash_key     = var.hash_key

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = false
  }
}
