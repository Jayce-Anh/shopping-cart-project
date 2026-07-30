################################ KMS ################################
# Key policy follows AWS guides:
# - EKS secrets: https://docs.aws.amazon.com/eks/latest/userguide/enable-kms.html
# - EBS/ASG:     https://docs.aws.amazon.com/autoscaling/ec2/userguide/key-policy-requirements-EBS-encryption.html
# - EBS CSI:     https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_kms_key" "main" {
  description             = "${var.project.env}-${var.project.name} — shared CMK for all services"
  enable_key_rotation     = true
  deletion_window_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}"
  })
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project.env}-${var.project.name}"
  target_key_id = aws_kms_key.main.key_id
}

resource "aws_kms_key_policy" "main" {
  key_id = aws_kms_key.main.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        # Root account — full control over the key
        {
          Sid    = "RootFullAccess"
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${local.account_id}:root"
          }
          Action   = "kms:*"
          Resource = "*"
        },
        # CloudWatch Logs — encrypt log groups
        {
          Sid    = "CloudWatchLogs"
          Effect = "Allow"
          Principal = {
            Service = "logs.${var.project.region}.amazonaws.com"
          }
          Action = [
            "kms:Encrypt*", "kms:Decrypt*",
            "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:Describe*"
          ]
          Resource = "*"
          Condition = {
            ArnEquals = {
              "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${var.project.region}:${local.account_id}:log-group:*"
            }
          }
        },
        # Secrets Manager — encrypt secrets
        {
          Sid    = "SecretsManager"
          Effect = "Allow"
          Principal = {
            Service = "secretsmanager.amazonaws.com"
          }
          Action   = ["kms:Decrypt", "kms:GenerateDataKey", "kms:CreateGrant", "kms:DescribeKey"]
          Resource = "*"
        },
        # EKS control plane — envelope encryption (no GrantIsForAWSResource per AWS docs)
        {
          Sid    = "EKSService"
          Effect = "Allow"
          Principal = {
            Service = "eks.amazonaws.com"
          }
          Action   = ["kms:DescribeKey", "kms:CreateGrant"]
          Resource = "*"
        },
        # SQS — encrypt queue messages
        {
          Sid    = "SQS"
          Effect = "Allow"
          Principal = {
            Service = "sqs.amazonaws.com"
          }
          Action   = ["kms:GenerateDataKey", "kms:Decrypt", "kms:DescribeKey"]
          Resource = "*"
        },
        # SNS — encrypt topic messages
        {
          Sid    = "SNS"
          Effect = "Allow"
          Principal = {
            Service = "sns.amazonaws.com"
          }
          Action   = ["kms:GenerateDataKey", "kms:Decrypt", "kms:DescribeKey"]
          Resource = "*"
        },
        # EC2 EBS — AWS recommended ViaService condition
        {
          Sid    = "EC2EBSViaService"
          Effect = "Allow"
          Principal = {
            AWS = "*"
          }
          Action = [
            "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*",
            "kms:GenerateDataKey*", "kms:CreateGrant", "kms:DescribeKey"
          ]
          Resource = "*"
          Condition = {
            StringEquals = {
              "kms:CallerAccount" = local.account_id
              "kms:ViaService"    = "ec2.${var.project.region}.amazonaws.com"
            }
          }
        },
      ],
    )
  })
}
