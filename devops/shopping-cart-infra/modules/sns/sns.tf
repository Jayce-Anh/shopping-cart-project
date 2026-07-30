#SNS Topic
resource "aws_sns_topic" "cloudwatch-alarm" {
  name = "${var.project.env}-${var.project.name}-sns"
}

#SNS Topic Policy
resource "aws_sns_topic_policy" "cloudwatch-alarm" {
  arn    = aws_sns_topic.cloudwatch-alarm.arn
  policy = data.aws_iam_policy_document.sns_topic_cloudwatch_policy.json
  # lifecycle {
  #   ignore_changes = [ policy, ]
  # }
}

#SNS Topic Policy Document
data "aws_iam_policy_document" "sns_topic_cloudwatch_policy" {
  policy_id = "__default_policy_ID"

  statement {
    effect = "Allow"
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish"
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        var.project.account_id,
      ]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [aws_sns_topic.cloudwatch-alarm.arn]
  }
}

