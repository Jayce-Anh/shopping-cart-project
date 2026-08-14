################################ KMS ################################

#================= KMS Key =================#
resource "aws_kms_key" "kms" {
  description             = "Shared KMS key for all services"
  enable_key_rotation     = true
  deletion_window_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-shared-key"
  })
}

resource "aws_kms_alias" "kms" {
  name          = "alias/${var.project.env}-${var.project.name}-shared-key"
  target_key_id = aws_kms_key.kms.key_id
}

#================= KMS Key Policy =================#
resource "aws_kms_key_policy" "kms" {
  key_id = aws_kms_key.kms.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        # Root account - Full control over this key
        {
          Sid    = "RootFullAccess"
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${var.project.account_id}:root"
          }
          Action   = "kms:*"
          Resource = "*"
        },
        # CloudWatch Logs
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
              "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${var.project.region}:${var.project.account_id}:log-group:*"
            }
          }
        },
        # Secrets Manager 
        {
          Sid    = "SecretsManager"
          Effect = "Allow"
          Principal = {
            Service = "secretsmanager.amazonaws.com"
          }
          Action   = ["kms:Decrypt", "kms:GenerateDataKey", "kms:CreateGrant", "kms:DescribeKey"]
          Resource = "*"
        },
        # EKS control plane
        {
          Sid    = "EKSService"
          Effect = "Allow"
          Principal = {
            Service = "eks.amazonaws.com"
          }
          Action   = ["kms:DescribeKey", "kms:CreateGrant"]
          Resource = "*"
        },
        # SQS
        {
          Sid    = "SQS"
          Effect = "Allow"
          Principal = {
            Service = "sqs.amazonaws.com"
          }
          Action   = ["kms:GenerateDataKey", "kms:Decrypt", "kms:DescribeKey"]
          Resource = "*"
        },
        # SNS
        {
          Sid    = "SNS"
          Effect = "Allow"
          Principal = {
            Service = "sns.amazonaws.com"
          }
          Action   = ["kms:GenerateDataKey", "kms:Decrypt", "kms:DescribeKey"]
          Resource = "*"
        },
        # EC2 EBS
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
              "kms:CallerAccount" = "${var.project.account_id}"
              "kms:ViaService"    = "ec2.${var.project.region}.amazonaws.com"
            }
          }
        },
        # RDS
        {
          Sid    = "RDSViaService"
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
              "kms:CallerAccount" = "${var.project.account_id}"
              "kms:ViaService"    = "rds.${var.project.region}.amazonaws.com"
            }
          }
        },
        # ElastiCache
        {
          Sid    = "ElastiCacheViaService"
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
              "kms:CallerAccount" = "${var.project.account_id}"
              "kms:ViaService"    = "elasticache.${var.project.region}.amazonaws.com"
            }
          }
        },
        # ECR
        {
          Sid    = "ECRViaService"
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
              "kms:CallerAccount" = "${var.project.account_id}"
              "kms:ViaService"    = "ecr.${var.project.region}.amazonaws.com"
            }
          }
        },
      ],
    )
  })
}
