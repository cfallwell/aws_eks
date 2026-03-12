# aws_eks

EKS infrastructure, Argo CD bootstrap, and an EKS-compatible GitOps workload set.

## Repository Layout

- `terraform/`: AWS infrastructure, cluster bootstrap, IAM, storage, and Terraform inputs.
- `kubernetes/charts`: Helm charts managed by Argo CD.
- `kubernetes/flux`: legacy Flux sources and app-of-apps definitions retained during migration.
- `kubernetes/apps/kube-system`: EKS platform add-ons and storage primitives.
- `kubernetes/apps/monitoring`: Splunk OpenTelemetry deployment with overlayable values.
- `kubernetes/apps/spa-demo`: Self-contained SPA source plus deployment manifests.

## What This Creates

- An externally reachable EKS cluster with public API access controls.
- A default encrypted `gp3` EBS `StorageClass`.
- An application S3 bucket with IRSA access for in-cluster workloads.
- Argo CD installed by Terraform and bootstrapped against this repository.
- AWS Load Balancer Controller for public ingress on EKS.
- Splunk OpenTelemetry as the monitoring baseline.
- The `spa-demo` workload delivered from a Helm chart through Argo CD.

## Apply Flow

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

Terraform installs the selected GitOps controller, bootstraps the cluster entrypoint, and outputs the
`aws eks update-kubeconfig` command for the cluster.

## Current Migration State

This branch stages the move away from Flux/Kustomize:

- Terraform now defaults to `gitops_controller = "argocd"`.
- Argo CD is installed and bootstraps the `spa-demo` application from `kubernetes/charts/spa-demo`.
- The `gp3` `StorageClass`, `spa-demo` namespace, `spa-demo-db` secret, and AWS Load Balancer Controller are managed directly by Terraform for the Argo CD path.
- The existing `kubernetes/flux` tree remains in the repository as a migration reference until the remaining add-ons are converted.

Use [docs/argocd-migration.md](/Users/fall1972/repo/aws_eks/docs/argocd-migration.md) for the exact cutover procedure.
