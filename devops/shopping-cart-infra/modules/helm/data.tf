# Provider blocks are configured in the root module
# Data sources below are used only for the time_sleep dependency.

data "aws_eks_cluster" "main" {
  name = var.helm_eks_cluster_id
}

data "aws_eks_cluster_auth" "main" {
  name = var.helm_eks_cluster_id
}

# Wait for 5 minutes to ensure the EKS cluster is ready
# resource "time_sleep" "wait" {
#   create_duration = "5m"
#   depends_on      = [data.aws_eks_cluster.main]
# }

