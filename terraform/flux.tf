resource "helm_release" "flux" {
  name             = "flux2"
  chart            = "oci://ghcr.io/fluxcd-community/charts/flux2"
  namespace        = "flux-system"
  create_namespace = true
  values           = [yamlencode({ installCRDs = true })]
}

locals {
  flux_bootstrap_manifest = templatefile("${path.module}/templates/flux-bootstrap.yaml.tftpl", {
    flux_repository_url                   = var.flux_repository_url
    flux_repository_branch                = var.flux_repository_branch
    aws_region                            = var.region
    cluster_name                          = module.eks.cluster_name
    spa_demo_host                         = var.spa_demo_host
    spa_demo_storage_size                 = var.spa_demo_storage_size
    spa_demo_s3_bucket_name               = aws_s3_bucket.spa_demo.bucket
    spa_demo_s3_role_arn                  = aws_iam_role.spa_demo_s3.arn
    aws_load_balancer_controller_role_arn = module.aws_load_balancer_controller_irsa.arn
    splunk_otel_cluster_name              = local.splunk_cluster_name
    splunk_observability_realm            = var.splunk_observability_realm
    splunk_observability_access_token_b64 = base64encode(var.splunk_observability_access_token)
    splunk_platform_endpoint_b64          = base64encode(var.splunk_platform_endpoint)
    splunk_platform_token_b64             = base64encode(var.splunk_platform_token)
    spa_demo_db_endpoint_b64              = base64encode(aws_db_instance.spa_demo.address)
    spa_demo_db_name_b64                  = base64encode(var.spa_demo_db_name)
    spa_demo_db_username_b64              = base64encode(var.spa_demo_db_username)
    spa_demo_db_password_b64              = base64encode(random_password.spa_demo_db.result)
  })
}

resource "null_resource" "flux_bootstrap" {
  triggers = {
    manifest_sha = sha256(local.flux_bootstrap_manifest)
    cluster_name = module.eks.cluster_name
    region       = var.region
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}
      cat <<'EOF' | kubectl apply -f -
      ${local.flux_bootstrap_manifest}
      EOF
    EOT
  }

  depends_on = [
    null_resource.kubeconfig,
    helm_release.flux,
    aws_db_instance.spa_demo,
    aws_s3_bucket.spa_demo,
    aws_iam_role.spa_demo_s3,
    module.aws_load_balancer_controller_irsa,
  ]
}
