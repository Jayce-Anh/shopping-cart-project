################################### CODE PIPELINE/BUILD/DEPLOY - IAM ############################################

#================= CodePipeline =================#
# Role
resource "aws_iam_role" "pipeline_role" {
  name = "${var.project.env}-${var.project.name}-codepipeline"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Policy
resource "aws_iam_role_policy" "codepipeline_policy" {
  role = aws_iam_role.pipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:PassRole"
        ],
        Resource = "*",
        Effect   = "Allow",
        Condition = {
          StringEqualsIfExists = {
            "iam:PassedToService" = [
              "cloudformation.amazonaws.com",
              "elasticbeanstalk.amazonaws.com",
              "ec2.amazonaws.com",
              "ecs-tasks.amazonaws.com"
            ]
          }
        }
      },
      {
        Action = [
          "codecommit:CancelUploadArchive",
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetRepository",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:UploadArchive"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "codestar-connections:UseConnection"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "elasticbeanstalk:*",
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "cloudwatch:*",
          "s3:*",
          "sns:*",
          "cloudformation:*",
          "rds:*",
          "sqs:*",
          "ecs:*"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "lambda:InvokeFunction",
          "lambda:ListFunctions"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "opsworks:CreateDeployment",
          "opsworks:DescribeApps",
          "opsworks:DescribeCommands",
          "opsworks:DescribeDeployments",
          "opsworks:DescribeInstances",
          "opsworks:DescribeStacks",
          "opsworks:UpdateApp",
          "opsworks:UpdateStack"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "cloudformation:CreateStack",
          "cloudformation:DeleteStack",
          "cloudformation:DescribeStacks",
          "cloudformation:UpdateStack",
          "cloudformation:CreateChangeSet",
          "cloudformation:DeleteChangeSet",
          "cloudformation:DescribeChangeSet",
          "cloudformation:ExecuteChangeSet",
          "cloudformation:SetStackPolicy",
          "cloudformation:ValidateTemplate"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuildBatches",
          "codebuild:StartBuildBatch"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Effect = "Allow",
        Action = [
          "devicefarm:ListProjects",
          "devicefarm:ListDevicePools",
          "devicefarm:GetRun",
          "devicefarm:GetUpload",
          "devicefarm:CreateUpload",
          "devicefarm:ScheduleRun"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "servicecatalog:ListProvisioningArtifacts",
          "servicecatalog:CreateProvisioningArtifact",
          "servicecatalog:DescribeProvisioningArtifact",
          "servicecatalog:DeleteProvisioningArtifact",
          "servicecatalog:UpdateProduct"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "cloudformation:ValidateTemplate"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:DescribeImages"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "states:DescribeExecution",
          "states:DescribeStateMachine",
          "states:StartExecution"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "appconfig:StartDeployment",
          "appconfig:StopDeployment",
          "appconfig:GetDeployment"
        ],
        Resource = "*"
      }
    ]
  })
}

#================= CodeBuild =================#
# Role
resource "aws_iam_role" "codebuild_role" {
  name = "${var.project.env}-${var.project.name}-codebuild"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

}

# Policy
resource "aws_iam_role_policy" "s3_policy_cicd" {
  role = aws_iam_role.codebuild_role.name

  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Resource = [
            "*"
          ],
          Action = [
            "logs:*"
          ]
        },
        {
          Effect = "Allow",
          Resource = [
            "*"
          ],
          Action = [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:CompleteLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:InitiateLayerUpload",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetAuthorizationToken",
            "ecr:PutImage"
          ]
        },
        {
          Effect = "Allow",
          Resource = [
            "*"
          ],
          Action = [
            "ssm:DescribeParameters",
            "ssm:GetParameter"
          ]
        },
        {
          Effect = "Allow",
          Resource = [
            "*"
          ],
          Action = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:DeleteObject"
          ]
        },
        {
          Action = [
            "cloudfront:CreateInvalidation",
            "cloudfront:GetDistribution",
            "cloudfront:GetStreamingDistribution",
            "cloudfront:GetDistributionConfig",
            "cloudfront:GetInvalidation",
            "cloudfront:ListInvalidations",
            "cloudfront:ListStreamingDistributions",
            "cloudfront:ListDistributions"
          ],
          Effect = "Allow",
          Resource = [
            "*"
          ],
        },
        {
          Effect = "Allow",
          Resource = [
            aws_s3_bucket.bucket_artifact.arn,
            "${aws_s3_bucket.bucket_artifact.arn}/*"
          ],
          Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:PutObjectTagging",
            "s3:GetObjectVersion",
            "s3:GetBucketVersioning",
          ]
        }
      ]
    }
  )
}

#================= CodeDeploy =================#
# # Role
# resource "aws_iam_role" "codedeploy_role" {
#   name               = "${var.project.env}-${var.project.name}-codedeploy"
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "codedeploy.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }

# # Policy
# resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
#   count = var.enable_codedeploy ? 1 : 0

#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
#   role       = aws_iam_role.codedeploy_role[0].name
# }

# resource "aws_iam_role_policy_attachment" "AWSCodeDeployRoleForECS" {
#   count = var.enable_codedeploy ? 1 : 0

#   policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
#   role       = aws_iam_role.codedeploy_role[0].name
# }