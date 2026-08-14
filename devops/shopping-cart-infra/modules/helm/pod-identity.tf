####################################### POD IDENTITY ######################################

#================= Pod Identity Trust Policy =================#
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

#================= Role =================#
# External Secrets
resource "aws_iam_role" "external_secrets" {
  name               = "${var.project.env}-${var.project.name}-external-secrets"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-external-secrets"  
  })
}

# Inventory
resource "aws_iam_role" "pod_identity_inventory" {
  name               = "${var.project.env}-${var.project.name}-inventory-pod-identity"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-inventory-pod-identity"
  })
}

# Order
resource "aws_iam_role" "pod_identity_order" {
  name               = "${var.project.env}-${var.project.name}-order-pod-identity"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-order-pod-identity"
  })
}

#================= Policy =================#
# External Secrets
resource "aws_iam_role_policy" "external_secrets" {
  name = "${var.project.env}-${var.project.name}-external-secrets"
  role = aws_iam_role.external_secrets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = [
          "${aws_secretsmanager_secret.helm-addon.arn}",
          "${aws_secretsmanager_secret.helm-git-token.arn}",
          "${var.helm_rds_secret_arn}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
        ]
        Resource = "${var.helm_kms_key}"
      },
    ]
  })
}

# Inventory
resource "aws_iam_role_policy" "inventory_sqs" {
  name = "${var.project.env}-${var.project.name}-inventory-sqs"
  role = aws_iam_role.pod_identity_inventory.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ChangeMessageVisibility",
        ]
        Resource = ["${var.helm_sqs_queue_arn}"]
      },
    ]
  })
}

# Order
resource "aws_iam_role_policy" "order_sqs" {
  name = "${var.project.env}-${var.project.name}-order-sqs"
  role = aws_iam_role.pod_identity_order.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ChangeMessageVisibility",
        ]
        Resource = ["${var.helm_sqs_queue_arn}"]
      },
    ]
  })
}

#================= Pod Identity Association =================#
resource "aws_eks_pod_identity_association" "external_secrets" {
  cluster_name    = var.helm_eks_cluster
  namespace       = "kube-system"
  service_account = "external-secrets"
  role_arn        = aws_iam_role.external_secrets.arn
}

resource "aws_eks_pod_identity_association" "alb_controller" {
  cluster_name    = var.helm_eks_cluster
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.alb_controller.arn
}

resource "aws_eks_pod_identity_association" "cluster_autoscaler" {
  cluster_name    = var.helm_eks_cluster
  namespace       = "kube-system"
  service_account = "cluster-autoscaler"
  role_arn        = aws_iam_role.cluster_autoscaler.arn
}

resource "aws_eks_pod_identity_association" "argocd" {
  cluster_name    = var.helm_eks_cluster
  namespace       = "argocd"
  service_account = "argocd-server"
  role_arn        = aws_iam_role.argocd.arn
}

resource "aws_eks_pod_identity_association" "karpenter" {
  cluster_name    = var.helm_eks_cluster
  namespace       = "karpenter"
  service_account = "karpenter"
  role_arn        = aws_iam_role.karpenter.arn
}

resource "aws_eks_pod_identity_association" "inventory" {
  cluster_name    = var.helm_eks_cluster
  namespace       = var.project.name
  service_account = "inventory"
  role_arn        = aws_iam_role.pod_identity_inventory.arn
}

resource "aws_eks_pod_identity_association" "order" {
  cluster_name    = var.helm_eks_cluster
  namespace       = var.project.name
  service_account = "order"
  role_arn        = aws_iam_role.pod_identity_order.arn
}
