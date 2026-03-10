data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

locals {
  name = var.name
  azs  = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  spa_demo_s3_bucket_name = var.spa_demo_s3_bucket_name != "" ? var.spa_demo_s3_bucket_name : "${local.name}-${data.aws_caller_identity.current.account_id}-${random_string.s3_suffix.result}"
  splunk_cluster_name     = var.splunk_otel_cluster_name != "" ? var.splunk_otel_cluster_name : local.name

  common_tags = merge(
    {
      Project                      = local.name
      splunkit_data_classification = "private"
      splunkit_environment_type    = "non-prd"
    },
    var.tags
  )
}

resource "random_string" "s3_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "null_resource" "kubeconfig" {
  triggers = {
    cluster_name = module.eks.cluster_name
    region       = var.region
  }

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
  }
}
