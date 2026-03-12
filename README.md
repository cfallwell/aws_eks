# aws_eks

EKS infrastructure, Flux bootstrap, and an EKS-compatible GitOps workload set.

## Repository Layout

- `*.tf`: AWS infrastructure, cluster bootstrap, IAM, and storage.
- `kubernetes/flux`: Flux sources and app-of-apps definitions.
- `kubernetes/apps/kube-system`: EKS platform add-ons and storage primitives.
- `kubernetes/apps/monitoring`: Splunk OpenTelemetry deployment with overlayable values.
- `kubernetes/apps/spa-demo`: Self-contained SPA source plus deployment manifests.

## What This Creates

- An externally reachable EKS cluster with public API access controls.
- A default encrypted `gp3` EBS `StorageClass`.
- An application S3 bucket with IRSA access for in-cluster workloads.
- Flux installed by Terraform and pointed back at this repository.
- AWS Load Balancer Controller for public ingress on EKS.
- Splunk OpenTelemetry as the monitoring baseline.
- The `spa-demo` workload as the only required application.

## Apply Flow

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

Terraform installs Flux, seeds the initial GitRepository/Kustomizations, and outputs the
`aws eks update-kubeconfig` command for the cluster.
