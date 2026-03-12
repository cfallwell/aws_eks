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
