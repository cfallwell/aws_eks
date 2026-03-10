data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = var.name
  azs  = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  common_tags = merge(
    {
      Project                      = local.name
      splunkit_data_classification = "private"
      splunkit_environment_type    = "non-prd"
    },
    var.tags
  )
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${local.name}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, i)]
  public_subnets  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, i + 8)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = local.common_tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = local.name
  kubernetes_version = var.kubernetes_version

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  endpoint_private_access      = true
  endpoint_public_access       = true
  endpoint_public_access_cidrs = var.public_access_cidrs

  enable_irsa                              = true
  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API_AND_CONFIG_MAP"

  addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
    eks-pod-identity-agent = {
      before_compute = true
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = aws_iam_role.ebs_csi_irsa.arn
    }
  }

  create_kms_key = true
  encryption_config = {
    resources = ["secrets"]
  }

  eks_managed_node_groups = {
    default = {
      instance_types = var.node_instance_types

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      iam_role_additional_policies = {
        ssm = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
    }
  }

  tags = local.common_tags
}

data "aws_iam_policy" "ebs_csi" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role" "ebs_csi_irsa" {
  name               = "${local.name}-ebs-csi-irsa"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi_irsa.name
  policy_arn = data.aws_iam_policy.ebs_csi.arn
}

data "aws_iam_policy_document" "ebs_csi_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_secretsmanager_secret" "pod" {
  count = var.enable_pod_secrets_provider ? 1 : 0

  name       = var.secrets_manager_secret_name
  kms_key_id = module.eks.kms_key_arn
  tags       = local.common_tags
}

resource "aws_secretsmanager_secret_version" "pod" {
  count = var.enable_pod_secrets_provider && var.secrets_manager_secret_value != "" ? 1 : 0

  secret_id     = aws_secretsmanager_secret.pod[0].id
  secret_string = var.secrets_manager_secret_value
}

data "aws_iam_policy_document" "secrets_reader" {
  count = var.enable_pod_secrets_provider ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
    ]
    resources = [aws_secretsmanager_secret.pod[0].arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]
    resources = [module.eks.kms_key_arn]
  }
}

resource "aws_iam_policy" "secrets_reader" {
  count  = var.enable_pod_secrets_provider ? 1 : 0
  name   = "${local.name}-secrets-reader"
  policy = data.aws_iam_policy_document.secrets_reader[0].json
  tags   = local.common_tags
}

data "aws_iam_policy_document" "secrets_reader_assume_role" {
  count = var.enable_pod_secrets_provider ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:${var.pod_secrets_namespace}:${var.pod_secrets_service_account}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "secrets_reader" {
  count              = var.enable_pod_secrets_provider ? 1 : 0
  name               = "${local.name}-secrets-reader"
  assume_role_policy = data.aws_iam_policy_document.secrets_reader_assume_role[0].json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "secrets_reader" {
  count      = var.enable_pod_secrets_provider ? 1 : 0
  role       = aws_iam_role.secrets_reader[0].name
  policy_arn = aws_iam_policy.secrets_reader[0].arn
}

resource "aws_security_group" "ssm_endpoints" {
  name        = "${local.name}-ssm-endpoints"
  description = "Allow HTTPS to SSM interface endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.ssm_endpoints.id]
  private_dns_enabled = true

  tags = local.common_tags
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.ssm_endpoints.id]
  private_dns_enabled = true

  tags = local.common_tags
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.ssm_endpoints.id]
  private_dns_enabled = true

  tags = local.common_tags
}

resource "kubernetes_storage_class_v1" "gp3" {
  count = var.enable_kubernetes_resources ? 1 : 0

  metadata {
    name = "${local.name}-gp3"
  }

  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  reclaim_policy      = "Delete"

  parameters = {
    type      = "gp3"
    encrypted = "true"
    fsType    = "ext4"
  }

  depends_on = [module.eks]
}

resource "kubernetes_persistent_volume_claim_v1" "ebs_100gb" {
  count = var.enable_kubernetes_resources ? 1 : 0

  metadata {
    name      = "${local.name}-pvc-100gb"
    namespace = "default"
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class_v1.gp3[0].metadata[0].name

    resources {
      requests = {
        storage = "100Gi"
      }
    }
  }

  wait_until_bound = false

  depends_on = [module.eks]
}

resource "kubernetes_service_account_v1" "secrets_reader" {
  count = var.enable_kubernetes_resources && var.enable_pod_secrets_provider ? 1 : 0

  metadata {
    name      = var.pod_secrets_service_account
    namespace = var.pod_secrets_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.secrets_reader[0].arn
    }
  }

  depends_on = [module.eks]
}

resource "null_resource" "kubeconfig" {
  triggers = {
    cluster_name = module.eks.cluster_name
    region       = var.region
  }

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
  }

  depends_on = [module.eks]
}
