################################# SQS #################################

resource "aws_sqs_queue" "queue" {
  name                       = "${var.project.env}-${var.project.name}-order-events"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 3600
  delay_seconds              = 0
  receive_wait_time_seconds  = 0
  fifo_queue                 = false
  kms_master_key_id          = var.sqs_kms_key

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-order-events"
  })
}
