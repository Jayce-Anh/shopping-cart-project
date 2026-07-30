#################################### RBAC ####################################

locals {
  default_map_roles = [
    {
      groups   = ["system:bootstrappers", "system:nodes"]
      rolearn  = aws_iam_role.node_group.arn
      username = "system:node:{{EC2PrivateDNSName}}"
    }
  ]

  mapRoles = distinct(concat(
    local.default_map_roles,
    var.map_roles,
  ))
}

# Note: EC2_LINUX access entry for the node group role is auto-created by AWS
# when the managed node group is provisioned. No manual resource needed.

# Additional access entries for custom roles
resource "aws_eks_access_entry" "additional_roles" {
  for_each = { for idx, role in var.map_roles : idx => role }

  cluster_name      = aws_eks_cluster.eks.name
  principal_arn     = each.value.rolearn
  kubernetes_groups = each.value.groups
  type              = "STANDARD"

  depends_on = [
    aws_eks_cluster.eks
  ]
}

# Admin access entries 
resource "aws_eks_access_entry" "admin" {
  for_each = var.eks_admin_access

  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = each.value
  type          = "STANDARD"

  depends_on = [aws_eks_cluster.eks]
}

resource "aws_eks_access_policy_association" "admin" {
  for_each = var.eks_admin_access

  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = each.value
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin]
}

# Legacy aws-auth ConfigMap (commented out - using access entries instead)
# resource "kubectl_manifest" "aws_auth" {
#   yaml_body = <<YAML
# apiVersion: v1
# kind: ConfigMap
# metadata:
#   labels:
#     app.kubernetes.io/managed-by: terraform
#   name: aws-auth
#   namespace: kube-system
# data:
#   mapAccounts: |
#     []
#   mapRoles: |
#     ${indent(4, yamlencode(local.mapRoles))}
#   mapUsers: |
#     []
# YAML
#
#   depends_on = [
#     aws_eks_cluster.eks,
#     aws_eks_node_group.node_groups
#   ]
# }
