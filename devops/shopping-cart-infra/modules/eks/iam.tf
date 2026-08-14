####################### EKS CLUSTER IAM ROLE #######################

#=========== EKS Cluster =============#
# Role
resource "aws_iam_role" "eks" {
  name = "${var.project.env}-${var.project.name}-eks-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-eks-cluster"
  })
}

# Attach Policies
resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks.name
}

# KMS
resource "aws_iam_role_policy" "eks_cluster_kms" {
  name = "${var.project.env}-${var.project.name}-eks-cluster-kms"
  role = aws_iam_role.eks.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["kms:DescribeKey", "kms:CreateGrant"]
        Resource = "${var.eks_kms_key}"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
        ]
        Resource = "${var.eks_kms_key}"
      },
    ]
  })
}

#=========== EKS Node Group =============#
# Role
resource "aws_iam_role" "node_group" {
  name = "${var.project.env}-${var.project.name}-eks-node-group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-eks-node-group"
  })
}

# Attach Policies
resource "aws_iam_role_policy_attachment" "node_group_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "node_group_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "node_group_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "node_group_AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.node_group.name
}

#=================== KMS =====================#
resource "aws_iam_role_policy" "node_group_kms" {
  name = "${var.project.env}-${var.project.name}-eks-node-group-kms"
  role = aws_iam_role.node_group.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant",
        ]
        Resource = "${var.eks_kms_key}"
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = "true"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
        ]
        Resource = "${var.eks_kms_key}"
      },
    ]
  })
}

resource "aws_iam_role_policy" "ebs_csi_driver_kms" {
  name = "${var.project.env}-${var.project.name}-eks-csi-driver-kms"
  role = aws_iam_role.ebs_csi_driver.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant",
        ]
        Resource = "${var.eks_kms_key}"
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = "true"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
        ]
        Resource = "${var.eks_kms_key}"
      },
    ]
  })
}

#=========== EBS CSI Driver =============#
# Role
resource "aws_iam_role" "ebs_csi_driver" {
  name = "${var.project.env}-${var.project.name}-eks-csi-driver"

  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-eks-csi-driver"
  })
}

# Attach Policy
resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver.name
}

#==================== Pod Identity =====================#
# Policy
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

# IRSA (OIDC) trust policy — disabled, replaced by EKS Pod Identity
# resource "aws_iam_role" "ebs_csi_driver" {
#   assume_role_policy = jsonencode({
#     Statement = [{
#       Effect = "Allow"
#       Principal = { Federated = aws_iam_openid_connect_provider.eks.arn }
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Condition = {
#         StringEquals = {
#           "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
#           "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" : "sts.amazonaws.com"
#         }
#       }
#     }]
#   })
# }

