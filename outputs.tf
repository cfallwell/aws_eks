output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API server endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for IRSA."
  value       = module.eks.cluster_oidc_issuer_url
}

output "kubeconfig_command" {
  description = "Command to configure kubeconfig for this cluster."
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "secrets_manager_secret_arn" {
  description = "Secrets Manager secret ARN for pod access (when enabled)."
  value       = try(aws_secretsmanager_secret.pod[0].arn, null)
}

output "pod_secrets_service_account" {
  description = "Service account annotated for Secrets Manager access (when enabled)."
  value       = try(kubernetes_service_account_v1.secrets_reader[0].metadata[0].name, null)
}

output "spa_demo_db_endpoint" {
  description = "RDS endpoint for the spa-demo PostgreSQL database."
  value       = aws_db_instance.spa_demo.address
}

output "spa_demo_db_secret_name" {
  description = "Kubernetes secret used by the spa-demo API to connect to PostgreSQL."
  value       = try(kubernetes_secret_v1.spa_demo_db[0].metadata[0].name, null)
}
