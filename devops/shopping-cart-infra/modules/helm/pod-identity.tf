####################################### POD IDENTITY ######################################

#==================== Addon Pod Identity ========================#
data "aws_iam_policy_document" "pod_identity_trust" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

# External Secrets
resource "aws_iam_role" "external_secrets" {
  count = var.helm_enable_addons.ex_secrets ? 1 : 0

  name               = "${var.project.env}-${var.project.name}-external-secrets-role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-external-secrets-role"
  })
}

resource "aws_iam_role_policy" "external_secrets" {
  count = var.helm_enable_addons.ex_secrets ? 1 : 0

  name = "${var.project.env}-${var.project.name}-external-secrets-policy"
  role = aws_iam_role.external_secrets[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [{
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_ids[0]}:secret:${var.project.env}-${var.project.name}-*"
      }],
      var.enable_kms ? [{
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
        ]
        Resource = var.kms_key_arn
      }] : [],
    )
  })
}

resource "aws_eks_pod_identity_association" "external_secrets" {
  count = var.helm_enable_addons.ex_secrets ? 1 : 0

  cluster_name    = var.helm_eks_cluster_id
  namespace       = "kube-system"
  service_account = "external-secrets"
  role_arn        = aws_iam_role.external_secrets[0].arn
}

# AWS Load Balancer Controller
resource "aws_eks_pod_identity_association" "alb_controller" {
  cluster_name    = var.helm_eks_cluster_id
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.alb_controller.arn
}

# Cluster Autoscaler
resource "aws_eks_pod_identity_association" "cluster_autoscaler" {
  count = var.helm_enable_addons.cluster_autoscaler ? 1 : 0

  cluster_name    = var.helm_eks_cluster_id
  namespace       = "kube-system"
  service_account = "cluster-autoscaler"
  role_arn        = aws_iam_role.cluster_autoscaler[0].arn
}

# ArgoCD
resource "aws_eks_pod_identity_association" "argocd" {
  count = var.helm_enable_addons.argocd ? 1 : 0

  cluster_name    = var.helm_eks_cluster_id
  namespace       = "argocd"
  service_account = "argocd-server"
  role_arn        = aws_iam_role.argocd[0].arn
}

# Karpenter
resource "aws_eks_pod_identity_association" "karpenter" {
  count = var.helm_enable_addons.karpenter ? 1 : 0

  cluster_name    = var.helm_eks_cluster_id
  namespace       = "karpenter"
  service_account = "karpenter"
  role_arn        = aws_iam_role.karpenter[0].arn
}


#==================== App Service Accounts ========================#
resource "aws_eks_pod_identity_association" "service_account" {
  for_each = var.helm_pod_identity_roles

  cluster_name    = var.helm_eks_cluster_id
  namespace       = each.value.namespace
  service_account = each.value.service_account
  role_arn        = aws_iam_role.pod_identity_role[each.key].arn

  depends_on = [
    aws_iam_role.pod_identity_role,
    aws_iam_role_policy.pod_identity_role_inline,
    aws_iam_role_policy_attachment.pod_identity_role,
  ]
}

# Pod Identity Policies
locals {
  policy_version = "2012-10-17"
  policy_effect  = "Allow"

  actions = {
    sqs-access = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ChangeMessageVisibility",
    ]
    s3-read = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    s3-full = ["s3:*"]
    secretsmanager-access = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    dynamodb-access = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan",
    ]
    kms-decrypt = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey",
    ]
    cognito-access = [
      "cognito-idp:AdminGetUser",
      "cognito-idp:ListUsers",
      "cognito-idp:AdminCreateUser",
      "cognito-idp:AdminUpdateUserAttributes",
    ]
    cloudwatch-metrics = [
      "cloudwatch:PutMetricData",
      "cloudwatch:GetMetricData",
      "cloudwatch:ListMetrics",
    ]
    logs-write = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    elasticache-access = [
      "elasticache:Connect",
      "elasticache:DescribeReplicationGroups",
    ]
    rds-describe = [
      "rds:DescribeDBInstances",
      "rds:DescribeDBClusters",
    ]
    sts-access = [
      "sts:AssumeRole",
      "sts:GetCallerIdentity",
    ]
    ec2-describe = [
      "ec2:DescribeInstances",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
    ]
    ecs-describe = [
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:DescribeServices",
    ]
    eks-describe = [
      "eks:DescribeCluster",
      "eks:ListClusters",
    ]
    iam-service-linked-role = [
      "iam:CreateServiceLinkedRole",
    ]
  }

  pod_identity_inline_policies = flatten([
    for role_key, role in var.helm_pod_identity_roles : [
      for policy_key, policy in role.inline_policies : {
        id         = "${role_key}-${policy_key}"
        role_key   = role_key
        policy_key = policy_key
        actions    = local.actions[policy_key]
        resources  = policy.resources
      }
    ]
  ])
}

#==================== Pod Identity Roles ========================#
resource "aws_iam_role" "pod_identity_role" {
  for_each = var.helm_pod_identity_roles

  name               = "${var.project.env}-${var.project.name}-${each.key}-pod-identity-role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${each.key}-pod-identity-role"
  })
}

#==================== Pod Identity Policies ========================#
resource "aws_iam_role_policy" "pod_identity_role_inline" {
  for_each = {
    for policy in local.pod_identity_inline_policies : policy.id => policy
  }

  name = "${var.project.env}-${var.project.name}-${each.value.role_key}-${each.value.policy_key}-policy"
  role = aws_iam_role.pod_identity_role[each.value.role_key].id

  policy = jsonencode({
    Version = local.policy_version
    Statement = [
      {
        Effect   = local.policy_effect
        Action   = each.value.actions
        Resource = each.value.resources
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "pod_identity_role" {
  for_each = {
    for pair in flatten([
      for role_key, role in var.helm_pod_identity_roles : [
        for idx, policy_arn in role.policy_arns : {
          id         = "${role_key}-${idx}"
          role_key   = role_key
          policy_arn = policy_arn
        }
      ]
    ]) : pair.id => pair
  }

  role       = aws_iam_role.pod_identity_role[each.value.role_key].name
  policy_arn = each.value.policy_arn
}
