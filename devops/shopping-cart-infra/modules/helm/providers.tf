############################# HELM PROVIDERS #############################

resource "terraform_data" "eks_nodes" {
  input = var.helm_eks_node_group_id
}

data "aws_eks_cluster" "main" {
  name = var.helm_eks_cluster
}

data "aws_eks_cluster_auth" "main" {
  name = var.helm_eks_cluster
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.main.token
  }
}
