resource "helm_release" "flux" {
  name             = "flux2"
  repository       = "https://fluxcd-community.github.io/helm-charts"
  chart            = "flux2"
  namespace        = "flux-system"
  create_namespace = true
  values           = [yamlencode({ installCRDs = true })]
}

resource "kubernetes_config_map_v1" "cluster_settings" {
  metadata {
    name      = "cluster-settings"
    namespace = "flux-system"
  }

  data = {
    aws_region                            = var.region
    cluster_name                          = module.eks.cluster_name
    spa_demo_host                         = var.spa_demo_host
    spa_demo_storage_size                 = var.spa_demo_storage_size
    spa_demo_s3_bucket_name               = aws_s3_bucket.spa_demo.bucket
    spa_demo_s3_role_arn                  = aws_iam_role.spa_demo_s3.arn
    aws_load_balancer_controller_role_arn = module.aws_load_balancer_controller_irsa.arn
    splunk_otel_cluster_name              = local.splunk_cluster_name
    splunk_otel_suspend                   = tostring(var.splunk_otel_suspend)
    splunk_observability_realm            = var.splunk_observability_realm
  }

  depends_on = [helm_release.flux]
}

resource "kubernetes_secret_v1" "cluster_secrets" {
  metadata {
    name      = "cluster-secrets"
    namespace = "flux-system"
  }

  data = {
    splunk_observability_access_token = var.splunk_observability_access_token
    splunk_platform_endpoint          = var.splunk_platform_endpoint
    splunk_platform_token             = var.splunk_platform_token
    spa_demo_db_endpoint              = aws_db_instance.spa_demo.address
    spa_demo_db_name                  = var.spa_demo_db_name
    spa_demo_db_username              = var.spa_demo_db_username
    spa_demo_db_password              = random_password.spa_demo_db.result
  }

  type       = "Opaque"
  depends_on = [helm_release.flux]
}

resource "kubernetes_manifest" "flux_repo" {
  manifest = {
    apiVersion = "source.toolkit.fluxcd.io/v1"
    kind       = "GitRepository"
    metadata = {
      name      = "platform-repo"
      namespace = "flux-system"
    }
    spec = {
      interval = "1m"
      url      = var.flux_repository_url
      ref = {
        branch = var.flux_repository_branch
      }
    }
  }

  depends_on = [helm_release.flux]
}

resource "kubernetes_manifest" "flux_root" {
  manifest = {
    apiVersion = "kustomize.toolkit.fluxcd.io/v1"
    kind       = "Kustomization"
    metadata = {
      name      = "platform-root"
      namespace = "flux-system"
    }
    spec = {
      interval = "10m"
      path     = "./kubernetes/flux"
      prune    = true
      wait     = true
      sourceRef = {
        kind = "GitRepository"
        name = "platform-repo"
      }
      postBuild = {
        substituteFrom = [
          {
            kind = "ConfigMap"
            name = "cluster-settings"
          },
          {
            kind     = "Secret"
            name     = "cluster-secrets"
            optional = true
          }
        ]
      }
    }
  }

  depends_on = [
    helm_release.flux,
    kubernetes_config_map_v1.cluster_settings,
    kubernetes_secret_v1.cluster_secrets,
    kubernetes_manifest.flux_repo,
  ]
}
