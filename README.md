# aws_eks

EKS infrastructure, Argo CD bootstrap, and the `spa-demo` application source.

## Repository Layout

- `terraform/`: AWS infrastructure, cluster bootstrap, IAM, storage, and Terraform inputs.
- `apps/spa-demo`: The SPA source, API server, and build output used by the demo workload.
- `charts/`: Helm charts reconciled by Argo CD.

## What This Creates

- An externally reachable EKS cluster with public API access controls.
- A default encrypted `gp3` EBS `StorageClass`.
- An application S3 bucket with IRSA access for in-cluster workloads.
- Argo CD installed by Terraform and bootstrapped against this repository.
- AWS Load Balancer Controller for public ingress on EKS.
- The `spa-demo` workload delivered from a Helm chart through Argo CD.
- A reusable SignalFx OpenTelemetry wrapper chart with an override values layer.

## Apply Flow

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

Terraform installs Argo CD, bootstraps the cluster entrypoint, and outputs the
`aws eks update-kubeconfig` command for the cluster.

## Current State

- Argo CD is installed and bootstraps the `spa-demo` application from `charts/spa-demo`.
- The `gp3` `StorageClass`, `spa-demo` namespace, `spa-demo-db` secret, and AWS Load Balancer Controller are managed directly by Terraform.
- The `spa-demo` application source now lives in `apps/spa-demo`.

Use [docs/argocd-migration.md](/Users/fall1972/repo/aws_eks/docs/argocd-migration.md) for the exact cutover procedure.
