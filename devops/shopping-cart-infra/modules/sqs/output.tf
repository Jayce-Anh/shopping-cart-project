############################## SQS OUTPUT ##############################

output "sqs_queue_name" {
  description = "SQS queue name"
  value       = aws_sqs_queue.queue.name
}

output "sqs_queue_arn" {
  description = "SQS queue ARN"
  value       = aws_sqs_queue.queue.arn
}

output "sqs_queue_url" {
  description = "SQS queue URL"
  value       = aws_sqs_queue.queue.url
}
