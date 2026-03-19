resource "kubernetes_secret_v1" "external_dns_cloudflare" {
  count = var.external_dns_enabled ? 1 : 0

  metadata {
    name      = "external-dns-cloudflare"
    namespace = var.external_dns_namespace
  }

  type = "Opaque"

  data = {
    apiToken = var.external_dns_cloudflare_api_token
  }

  depends_on = [time_sleep.eks_authz_ready]
}

resource "helm_release" "external_dns" {
  count = var.external_dns_enabled ? 1 : 0

  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  version          = var.external_dns_chart_version
  namespace        = var.external_dns_namespace
  create_namespace = false

  values = [
    yamlencode({
      provider = {
        name = "cloudflare"
      }
      sources            = ["ingress"]
      policy             = "upsert-only"
      registry           = "txt"
      txtOwnerId         = module.eks.cluster_name
      domainFilters      = var.external_dns_domain_filters
      triggerLoopOnEvent = true
      serviceAccount = {
        create = true
        name   = "external-dns"
      }
      env = [
        {
          name = "CF_API_TOKEN"
          valueFrom = {
            secretKeyRef = {
              name = kubernetes_secret_v1.external_dns_cloudflare[0].metadata[0].name
              key  = "apiToken"
            }
          }
        }
      ]
      extraArgs = {
        "ingress-class" = "alb"
      }
      resources = {
        requests = {
          cpu    = "50m"
          memory = "64Mi"
        }
        limits = {
          memory = "128Mi"
        }
      }
    })
  ]

  depends_on = [
    time_sleep.eks_authz_ready,
    helm_release.aws_load_balancer_controller,
    kubernetes_secret_v1.external_dns_cloudflare,
  ]

  lifecycle {
    precondition {
      condition     = trimspace(var.external_dns_cloudflare_api_token) != "" && length(var.external_dns_domain_filters) > 0
      error_message = "external_dns_enabled requires external_dns_cloudflare_api_token and at least one external_dns_domain_filters entry."
    }
  }
}
