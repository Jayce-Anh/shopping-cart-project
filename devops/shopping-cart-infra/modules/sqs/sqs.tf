################################# SQS #################################

resource "aws_sqs_queue" "queue" {
  name                       = var.sqs_fifo_queue ? "${var.project.env}-${var.project.name}-${var.sqs_name}.fifo" : "${var.project.env}-${var.project.name}-${var.sqs_name}"
  visibility_timeout_seconds = var.sqs_visibility_timeout
  message_retention_seconds  = var.sqs_message_retention_seconds
  delay_seconds              = var.sqs_delay_seconds
  receive_wait_time_seconds  = var.sqs_receive_wait_time_seconds
  fifo_queue                 = var.sqs_fifo_queue
  kms_master_key_id          = var.kms_key_arn

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.sqs_name}"
  })
}
