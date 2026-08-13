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

output "gitops_repository_branch" {
  description = "Git branch Argo CD is configured to reconcile."
  value       = var.gitops_repository_branch
}

output "argocd_ui_command" {
  description = "Command to port-forward the Argo CD UI locally."
  value       = "kubectl -n ${var.argocd_namespace} port-forward svc/argocd-server 8080:80"
}

output "spa_demo_s3_bucket_name" {
  description = "S3 bucket created for in-cluster workloads."
  value       = aws_s3_bucket.spa_demo.bucket
}

output "spa_demo_s3_role_arn" {
  description = "IRSA role granted to the spa-demo workload service account."
  value       = aws_iam_role.spa_demo_s3.arn
}

output "spa_demo_db_endpoint" {
  description = "RDS endpoint for the spa-demo PostgreSQL database."
  value       = aws_db_instance.spa_demo.address
}

output "spa_demo_db_secret_name" {
  description = "Kubernetes secret used by the spa-demo API to connect to PostgreSQL."
  value       = "spa-demo-db"
}

output "ec2_instance_public_dns" {
  description = "AWS-assigned public DNS name of the standalone EC2 instance (not tied to a named DNS zone)."
  value       = var.ec2_enabled ? one(aws_instance.ssh_demo[*].public_dns) : null
}

output "ec2_instance_public_ip" {
  description = "Public IPv4 address of the standalone EC2 instance."
  value       = var.ec2_enabled ? one(aws_instance.ssh_demo[*].public_ip) : null
}

output "ec2_ssh_usernames" {
  description = "Generated SSH usernames for the standalone EC2 instance."
  value = var.ec2_enabled ? {
    admin = local.ec2_admin_username
    user  = local.ec2_user_username
  } : null
}

output "ec2_ssh_accounts" {
  description = "Generated SSH accounts (username, password, sudo) for the standalone EC2 instance. Retrieve with: terraform output -json ec2_ssh_accounts"
  value       = var.ec2_enabled ? local.ec2_accounts : null
  sensitive   = true
}
