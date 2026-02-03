provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "this" {
  count = var.enable_kubernetes_resources ? 1 : 0
  name  = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  count = var.enable_kubernetes_resources ? 1 : 0
  name  = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = try(data.aws_eks_cluster.this[0].endpoint, "")
  cluster_ca_certificate = try(base64decode(data.aws_eks_cluster.this[0].certificate_authority[0].data), "")
  token                  = try(data.aws_eks_cluster_auth.this[0].token, "")
}
