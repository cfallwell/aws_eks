variable "region" {
  type        = string
  description = "AWS region to deploy into."
  default     = "us-east-1"

  validation {
    condition     = var.region == "us-east-1"
    error_message = "This project is pinned to us-east-1."
  }
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

variable "enable_kubernetes_resources" {
  type        = bool
  description = "Whether to manage in-cluster Kubernetes resources (StorageClass/PVC) via Terraform."
  default     = true
}

variable "enable_pod_secrets_provider" {
  type        = bool
  description = "Whether to provision AWS Secrets Manager + IRSA service account for pod secret access."
  default     = true
}

variable "pod_secrets_namespace" {
  type        = string
  description = "Namespace for the pod secrets service account."
  default     = "default"
}

variable "pod_secrets_service_account" {
  type        = string
  description = "Service account name for pods to read secrets from AWS."
  default     = "secrets-reader"
}

variable "secrets_manager_secret_name" {
  type        = string
  description = "AWS Secrets Manager secret name for pod access."
  default     = "awseks/pod-secrets"
}

variable "secrets_manager_secret_value" {
  type        = string
  description = "Optional secret value to store in AWS Secrets Manager (stored in TF state)."
  sensitive   = true
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
