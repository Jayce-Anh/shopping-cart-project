##################################### IAM #####################################

#==================== ArgoCD IAM Roles ========================#
# IRSA (OIDC) trust — disabled, replaced by EKS Pod Identity (see pod_identity.tf)
# data "aws_iam_policy_document" "argocd_trust" {
#   count = var.enable_addons.argocd ? 1 : 0
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     principals {
#       type        = "Federated"
#       identifiers = [var.oidc_provider_arn]
#     }
#     condition {
#       test     = "StringEquals"
#       variable = "${var.oidc_url}:sub"
#       values   = ["system:serviceaccount:argocd:argocd-server"]
#     }
#     condition {
#       test     = "StringEquals"
#       variable = "${var.oidc_url}:aud"
#       values   = ["sts.amazonaws.com"]
#     }
#   }
# }

resource "aws_iam_role" "argocd" {
  name               = "${var.project.env}-${var.project.name}-argocd"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-argocd"
  })
}

resource "aws_iam_role_policy" "argocd" {
  name = "${var.project.env}-${var.project.name}-argocd"
  role = aws_iam_role.argocd.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect   = "Allow"
          Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
          Resource = [
            "${aws_secretsmanager_secret.helm-addon.arn}",
            "${aws_secretsmanager_secret.helm-git-token.arn}",
          ]
        },
        {
          Effect   = "Allow"
          Action   = ["eks:DescribeCluster"]
          Resource = "*"
        },
      ],
      [{
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
        ]
        Resource = var.helm_kms_key
      }],
    )
  })
}

#======================= AWS Load Balancer Controller =========================#
# IRSA (OIDC) trust — disabled, replaced by EKS Pod Identity (see pod_identity.tf)
# data "aws_iam_policy_document" "alb_controller_trust" {
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     principals {
#       type        = "Federated"
#       identifiers = [var.oidc_provider_arn]
#     }
#     condition {
#       test     = "StringEquals"
#       variable = "${var.oidc_url}:sub"
#       values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
#     }
#     condition {
#       test     = "StringEquals"
#       variable = "${var.oidc_url}:aud"
#       values   = ["sts.amazonaws.com"]
#     }
#   }
# }

resource "aws_iam_policy" "alb_controller" {
  name        = "${var.project.env}-${var.project.name}-alb-controller"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["iam:CreateServiceLinkedRole"]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = "elasticloadbalancing.amazonaws.com"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTags",
          "ec2:DescribeRouteTables",
          "ec2:GetCoipPoolUsage",
          "ec2:DescribeCoipPools",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerAttributes",
          "elasticloadbalancing:DescribeListenerCertificates",
          "elasticloadbalancing:DescribeSSLPolicies",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeTrustStores"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:DescribeUserPoolClient",
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "iam:ListServerCertificates",
          "iam:GetServerCertificate",
          "waf-regional:GetWebACL",
          "waf-regional:GetWebACLForResource",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["ec2:AuthorizeSecurityGroupIngress", "ec2:RevokeSecurityGroupIngress"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["ec2:CreateSecurityGroup"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["ec2:CreateTags"]
        Resource = "arn:aws:ec2:*:*:security-group/*"
        Condition = {
          StringEquals = { "ec2:CreateAction" = "CreateSecurityGroup" }
          Null         = { "aws:RequestTag/elbv2.k8s.aws/cluster" = "false" }
        }
      },
      {
        Effect   = "Allow"
        Action   = ["ec2:CreateTags", "ec2:DeleteTags"]
        Resource = "arn:aws:ec2:*:*:security-group/*"
        Condition = {
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster"  = "true"
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },
      {
        Effect   = "Allow"
        Action   = ["ec2:AuthorizeSecurityGroupIngress", "ec2:RevokeSecurityGroupIngress", "ec2:DeleteSecurityGroup"]
        Resource = "*"
        Condition = {
          Null = { "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false" }
        }
      },
      {
        Effect   = "Allow"
        Action   = ["elasticloadbalancing:CreateLoadBalancer", "elasticloadbalancing:CreateTargetGroup"]
        Resource = "*"
        Condition = {
          Null = { "aws:RequestTag/elbv2.k8s.aws/cluster" = "false" }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["elasticloadbalancing:AddTags", "elasticloadbalancing:RemoveTags"]
        Resource = [
          "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
        ]
        Condition = {
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster"  = "true"
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },
      {
        Effect = "Allow"
        Action = ["elasticloadbalancing:AddTags", "elasticloadbalancing:RemoveTags"]
        Resource = [
          "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DeleteTargetGroup"
        ]
        Resource = "*"
        Condition = {
          Null = { "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false" }
        }
      },
      {
        Effect = "Allow"
        Action = ["elasticloadbalancing:AddTags"]
        Resource = [
          "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
        ]
        Condition = {
          StringEquals = {
            "elasticloadbalancing:CreateAction" = ["CreateTargetGroup", "CreateLoadBalancer"]
          }
          Null = { "aws:RequestTag/elbv2.k8s.aws/cluster" = "false" }
        }
      },
      {
        Effect   = "Allow"
        Action   = ["elasticloadbalancing:RegisterTargets", "elasticloadbalancing:DeregisterTargets"]
        Resource = "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:SetWebAcl",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:RemoveListenerCertificates",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:SetRulePriorities"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-alb-controller"
  })
}

resource "aws_iam_role" "alb_controller" {
  name               = "${var.project.env}-${var.project.name}-alb-controller"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-alb-controller"
  })
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  policy_arn = aws_iam_policy.alb_controller.arn
  role       = aws_iam_role.alb_controller.name
}

#======================= Cluster Autoscaler ==========================#
# IRSA (OIDC) trust — disabled, replaced by EKS Pod Identity (see pod_identity.tf)
# data "aws_iam_policy_document" "ca_trust" {
#   count = var.enable_addons.cluster_autoscaler ? 1 : 0
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     principals {
#       type        = "Federated"
#       identifiers = [var.oidc_provider_arn]
#     }
#     condition {
#       test     = "StringEquals"
#       variable = "${var.oidc_url}:sub"
#       values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
#     }
#     condition {
#       test     = "StringEquals"
#       variable = "${var.oidc_url}:aud"
#       values   = ["sts.amazonaws.com"]
#     }
#   }
# }

resource "aws_iam_role" "cluster_autoscaler" {
  name               = "${var.project.env}-${var.project.name}-cluster-autoscaler"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-cluster-autoscaler"
  })
}

resource "aws_iam_role_policy" "cluster_autoscaler" {
  name = "${var.project.env}-${var.project.name}-cluster-autoscaler"
  role = aws_iam_role.cluster_autoscaler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeImages",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = "*"
      }
    ]
  })
}

#======================== Karpenter =========================#
# IRSA (OIDC) trust — disabled, replaced by EKS Pod Identity (see pod_identity.tf)
# data "aws_iam_policy_document" "karpenter_trust" {
#   count = var.enable_addons.karpenter ? 1 : 0
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     principals {
#       type        = "Federated"
#       identifiers = [var.oidc_provider_arn]
#     }
#     condition {
#       test     = "StringEquals"
#       variable = "${var.oidc_url}:sub"
#       values   = ["system:serviceaccount:karpenter:karpenter"]
#     }
#     condition {
#       test     = "StringEquals"
#       variable = "${var.oidc_url}:aud"
#       values   = ["sts.amazonaws.com"]
#     }
#   }
# }

resource "aws_iam_role" "karpenter" {
  name               = "${var.project.env}-${var.project.name}-karpenter"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-karpenter"
  })
}

resource "aws_iam_role_policy" "karpenter" {
  name = "${var.project.env}-${var.project.name}-karpenter"
  role = aws_iam_role.karpenter.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateLaunchTemplate", "ec2:DeleteLaunchTemplate",
          "ec2:RunInstances", "ec2:TerminateInstances",
          "ec2:DescribeInstances", "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeSubnets", "ec2:DescribeSecurityGroups",
          "ec2:DescribeLaunchTemplates", "ec2:DescribeSpotPriceHistory",
          "ec2:CreateTags", "ec2:DeleteTags",
          "iam:PassRole",
          "ssm:GetParameter",
          "eks:DescribeCluster",
          "pricing:GetProducts"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action = [
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage",
        ]
        Resource = "${aws_sqs_queue.karpenter.arn}*"
      }
    ]
  })
}

# Interruption Queue Policy 
resource "aws_sqs_queue_policy" "karpenter" {
  queue_url = aws_sqs_queue.karpenter.url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2InterruptionPolicy"
        Effect = "Allow"
        Principal = {
          Service = [
            "events.amazonaws.com",
            "sqs.amazonaws.com",
          ]
        }
        Action   = "sqs:SendMessage"
        Resource = "${aws_sqs_queue.karpenter.arn}*"
      }
    ]
  })
}