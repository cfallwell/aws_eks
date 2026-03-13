resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  namespace        = var.argocd_namespace
  create_namespace = true

  values = [
    yamlencode({
      crds = {
        install = true
      }
      configs = {
        params = {
          "server.insecure" = true
        }
      }
      server = {
        service = {
          type = "ClusterIP"
        }
      }
    })
  ]
}

resource "kubernetes_secret_v1" "argocd_repository_credentials" {
  count = var.gitops_repository_username != "" && var.gitops_repository_password != "" ? 1 : 0

  metadata {
    name      = "gitops-repository-credentials"
    namespace = var.argocd_namespace

    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  type = "Opaque"

  data = {
    url      = var.gitops_repository_url
    type     = "git"
    username = var.gitops_repository_username
    password = var.gitops_repository_password
  }

  depends_on = [helm_release.argocd]
}

resource "kubernetes_namespace_v1" "spa_demo" {
  metadata {
    name = "spa-demo"
  }
}

resource "kubernetes_namespace_v1" "signalfx_otel" {
  count = var.signalfx_otel_enabled ? 1 : 0

  metadata {
    name = var.signalfx_otel_namespace
  }
}

resource "kubernetes_secret_v1" "signalfx_otel_credentials" {
  count = var.signalfx_otel_enabled ? 1 : 0

  metadata {
    name      = var.signalfx_otel_secret_name
    namespace = kubernetes_namespace_v1.signalfx_otel[0].metadata[0].name
  }

  type = "Opaque"

  data = {
    splunk_observability_access_token = var.signalfx_observability_access_token
    splunk_platform_hec_token         = var.signalfx_platform_hec_token
  }
}

resource "kubernetes_storage_class_v1" "gp3" {
  metadata {
    name = "gp3"

    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type      = "gp3"
    encrypted = "true"
    fsType    = "ext4"
  }
}

resource "kubernetes_secret_v1" "spa_demo_db" {
  metadata {
    name      = "spa-demo-db"
    namespace = kubernetes_namespace_v1.spa_demo.metadata[0].name
  }

  type = "Opaque"

  data = {
    DB_HOST     = aws_db_instance.spa_demo.address
    DB_PORT     = "5432"
    DB_NAME     = var.spa_demo_db_name
    DB_USER     = var.spa_demo_db_username
    DB_PASSWORD = random_password.spa_demo_db.result
    DB_SSLMODE  = "require"
    PORT        = "3000"
    NODE_ENV    = "production"
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  namespace        = "kube-system"
  create_namespace = false

  values = [
    yamlencode({
      clusterName                 = module.eks.cluster_name
      region                      = var.region
      vpcId                       = module.vpc.vpc_id
      replicaCount                = 2
      createIngressClassResource  = true
      ingressClass                = "alb"
      enableServiceMutatorWebhook = false
      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
        annotations = {
          "eks.amazonaws.com/role-arn" = module.aws_load_balancer_controller_irsa.arn
        }
      }
    })
  ]
}

locals {
  argocd_metrics_server_application_manifest = templatefile("${path.module}/templates/argocd-metrics-server-application.yaml.tftpl", {
    argocd_namespace         = var.argocd_namespace
    gitops_repository_url    = var.gitops_repository_url
    gitops_repository_branch = var.gitops_repository_branch
  })

  argocd_spa_demo_application_manifest = templatefile("${path.module}/templates/argocd-spa-demo-application.yaml.tftpl", {
    argocd_namespace         = var.argocd_namespace
    gitops_repository_url    = var.gitops_repository_url
    gitops_repository_branch = var.gitops_repository_branch
    signalfx_otel_namespace  = var.signalfx_otel_namespace
    spa_demo_host            = var.spa_demo_host
    spa_demo_storage_size    = var.spa_demo_storage_size
    spa_demo_s3_bucket_name  = aws_s3_bucket.spa_demo.bucket
    spa_demo_s3_role_arn     = aws_iam_role.spa_demo_s3.arn
  })

  argocd_signalfx_otel_application_manifest = templatefile("${path.module}/templates/argocd-signalfx-otel-application.yaml.tftpl", {
    argocd_namespace             = var.argocd_namespace
    gitops_repository_url        = var.gitops_repository_url
    gitops_repository_branch     = var.gitops_repository_branch
    signalfx_otel_namespace      = var.signalfx_otel_namespace
    signalfx_otel_secret_name    = var.signalfx_otel_secret_name
    signalfx_otel_cluster_name   = var.signalfx_otel_cluster_name
    signalfx_observability_realm = var.signalfx_observability_realm
    signalfx_platform_endpoint   = var.signalfx_platform_endpoint
  })

  argocd_bootstrap_manifest = join(
    "\n---\n",
    compact([
      local.argocd_metrics_server_application_manifest,
      local.argocd_spa_demo_application_manifest,
      var.signalfx_otel_enabled ? local.argocd_signalfx_otel_application_manifest : ""
    ])
  )
}

resource "null_resource" "argocd_bootstrap" {
  triggers = {
    manifest_sha = sha256(local.argocd_bootstrap_manifest)
    cluster_name = module.eks.cluster_name
    region       = var.region
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}
      cat <<'EOF' | kubectl apply -f -
      ${local.argocd_bootstrap_manifest}
      EOF
    EOT
  }

  depends_on = [
    null_resource.kubeconfig,
    helm_release.argocd,
    helm_release.aws_load_balancer_controller,
    kubernetes_secret_v1.argocd_repository_credentials,
    kubernetes_namespace_v1.spa_demo,
    kubernetes_namespace_v1.signalfx_otel,
    kubernetes_secret_v1.signalfx_otel_credentials,
    kubernetes_secret_v1.spa_demo_db,
    kubernetes_storage_class_v1.gp3,
    aws_db_instance.spa_demo,
    aws_s3_bucket.spa_demo,
    aws_iam_role.spa_demo_s3,
  ]
}
