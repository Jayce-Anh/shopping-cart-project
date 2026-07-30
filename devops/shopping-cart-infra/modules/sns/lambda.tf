#------------------------ Cloudwatch Alarm ------------------------

#IAM Role for Lambda
resource "aws_iam_role" "lambda-cloudwatch" {
  name = "${var.project.env}-${var.project.name}-lambda-cloudwatch-alarm"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

#IAM Policy for Lambda
resource "aws_iam_policy" "lambda-cloudwatch" {
  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:${var.project.region}:${var.project.account_id}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${var.project.region}:${var.project.account_id}:log-group:/aws/lambda/${var.project.env}-${var.project.name}-cloudwatch-alarm:*"
            ] 
        }
    ]
}
EOT
}

#Attach IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "lambda-cloudwatch" {
  role       = aws_iam_role.lambda-cloudwatch.name
  policy_arn = aws_iam_policy.lambda-cloudwatch.arn
}

#Create Lambda Function
resource "aws_lambda_function" "cloudwatch-alarm" {
  filename      = "cloudwatch_alarm.zip"
  function_name = "${var.project.env}-${var.project.name}-cloudwatch-alarm"
  role          = aws_iam_role.lambda-cloudwatch.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"
  environment {
    variables = {
      URL_GG_HOOK = var.URL_GG_HOOK
    }
  }
}

#Subcribe lambda to sns
resource "aws_sns_topic_subscription" "lambda-cloudwatch" {
  topic_arn = aws_sns_topic.cloudwatch-alarm.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.cloudwatch-alarm.arn
}

#Allow lambda to be invoked by sns
resource "aws_lambda_permission" "sns-cloudwatch" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudwatch-alarm.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.cloudwatch-alarm.arn
}