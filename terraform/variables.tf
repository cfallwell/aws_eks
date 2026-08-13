variable "region" {
  type        = string
  description = "AWS region to deploy into."
  default     = "us-east-1"
}

variable "name" {
  type        = string
  description = "Name prefix for resources."
  default     = "awseks"
}

variable "kubernetes_version" {
  type        = string
  description = "EKS Kubernetes version."
  default     = "1.33"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "az_count" {
  type        = number
  description = "Number of availability zones to use."
  default     = 3
}

variable "enable_private_aws_api_endpoints" {
  type        = bool
  description = "Whether to create private interface VPC endpoints for AWS APIs used by in-cluster controllers."
  default     = true
}

variable "public_access_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to access the EKS public API endpoint."
  default     = ["0.0.0.0/0"]
}

variable "node_instance_types" {
  type        = list(string)
  description = "Instance types for the managed node group."
  default     = ["m6i.large"]
}

variable "node_min_size" {
  type        = number
  description = "Minimum number of nodes in the managed node group."
  default     = 2
}

variable "node_max_size" {
  type        = number
  description = "Maximum number of nodes in the managed node group."
  default     = 6
}

variable "node_desired_size" {
  type        = number
  description = "Desired number of nodes in the managed node group."
  default     = 2
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to all resources."
  default     = {}
}

variable "ec2_enabled" {
  type        = bool
  description = "Whether to create the standalone SSH/Docker EC2 instance."
  default     = true
}

variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance size for the standalone SSH/Docker instance."
  default     = "t3.small"
}

variable "ec2_ssh_ingress_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to reach the EC2 instance over SSH (port 22). Defaults to 0.0.0.0/0 (open to all). Restrict to specific source CIDRs to limit exposure."
  default     = ["0.0.0.0/0"]
}

variable "ec2_root_volume_size" {
  type        = number
  description = "Root EBS volume size (GiB) for the standalone EC2 instance."
  default     = 30
}

variable "gitops_repository_url" {
  type        = string
  description = "Repository URL Argo CD should reconcile."
  default     = "https://github.com/cfallwell/aws_eks.git"
}

variable "gitops_repository_branch" {
  type        = string
  description = "Repository branch Argo CD should reconcile."
  default     = "main"
}

variable "gitops_repository_username" {
  type        = string
  description = "Optional username for Argo CD to authenticate to the GitOps repository when using HTTPS."
  default     = ""
}

variable "gitops_repository_password" {
  type        = string
  description = "Optional password or token for Argo CD to authenticate to the GitOps repository when using HTTPS."
  sensitive   = true
  default     = ""
}

variable "argocd_namespace" {
  type        = string
  description = "Namespace used for the Argo CD control plane."
  default     = "argocd"
}

variable "argocd_chart_version" {
  type        = string
  description = "Version of the Argo CD Helm chart to install."
  default     = "9.4.10"
}

variable "external_dns_enabled" {
  type        = bool
  description = "Whether to install external-dns for DNS automation."
  default     = false
}

variable "external_dns_namespace" {
  type        = string
  description = "Namespace used for the external-dns deployment."
  default     = "kube-system"
}

variable "external_dns_chart_version" {
  type        = string
  description = "Version of the external-dns Helm chart to install."
  default     = "1.20.0"
}

variable "external_dns_domain_filters" {
  type        = list(string)
  description = "Domain suffixes external-dns is allowed to manage."
  default     = []
}

variable "external_dns_cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token used by external-dns to manage DNS records."
  sensitive   = true
  default     = ""
}

variable "signalfx_otel_enabled" {
  type        = bool
  description = "Whether Argo CD should deploy the SignalFx OpenTelemetry collector."
  default     = false
}

variable "signalfx_otel_namespace" {
  type        = string
  description = "Namespace for the SignalFx OpenTelemetry collector."
  default     = "monitoring"
}

variable "signalfx_otel_cluster_name" {
  type        = string
  description = "Cluster name reported by the SignalFx OpenTelemetry collector."
  default     = ""
}

variable "signalfx_observability_realm" {
  type        = string
  description = "Splunk Observability Cloud realm for the SignalFx OpenTelemetry collector."
  default     = ""
}

variable "signalfx_observability_access_token" {
  type        = string
  description = "Splunk Observability Cloud access token for the SignalFx OpenTelemetry collector."
  sensitive   = true
  default     = ""
}

variable "signalfx_platform_endpoint" {
  type        = string
  description = "Splunk Platform HEC endpoint for the SignalFx OpenTelemetry collector."
  default     = ""
}

variable "signalfx_platform_hec_token" {
  type        = string
  description = "Splunk Platform HEC token for the SignalFx OpenTelemetry collector."
  sensitive   = true
  default     = ""
}

variable "signalfx_otel_secret_name" {
  type        = string
  description = "Name of the Kubernetes secret containing SignalFx OpenTelemetry credentials."
  default     = "signalfx-otel-credentials"
}

variable "spa_demo_s3_bucket_name" {
  type        = string
  description = "Optional explicit bucket name for workload S3 storage."
  default     = ""
}

variable "spa_demo_storage_size" {
  type        = string
  description = "Persistent EBS claim size for spa-demo."
  default     = "20Gi"
}

variable "spa_demo_host" {
  type        = string
  description = "Optional DNS host for the spa-demo ALB ingress."
  default     = ""
}

variable "spa_demo_db_name" {
  type        = string
  description = "PostgreSQL database name for the spa-demo API."
  default     = "spademo"
}

variable "spa_demo_db_username" {
  type        = string
  description = "PostgreSQL master username for the spa-demo API."
  default     = "spademo"
}

variable "spa_demo_db_instance_class" {
  type        = string
  description = "RDS instance class for the spa-demo PostgreSQL database."
  default     = "db.t4g.micro"
}

variable "spa_demo_db_allocated_storage" {
  type        = number
  description = "Allocated storage in GiB for the spa-demo PostgreSQL database."
  default     = 20
}
