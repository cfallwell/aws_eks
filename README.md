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
- A standalone EC2 instance (default `t3.small`) reachable over SSH with two
  randomly generated password logins and Docker preinstalled.

## Standalone EC2 (SSH + Docker)

Terraform provisions an Amazon Linux 2023 EC2 instance with Docker installed and
two randomly generated local accounts: one `user…` account and one `admin…`
account (each username carries 16 random characters and a 16-character complex
password). The `admin` account has full `sudo` (root) access via the `wheel`
group. Both accounts can use Docker.

Control the instance with these variables (see `terraform/variables.tf`):

- `ec2_instance_type` — instance size, default `t3.small`.
- `ec2_ssh_ingress_cidrs` — source CIDR(s) allowed to reach port 22. Defaults to
  `0.0.0.0/0` (open to all); restrict to your `/32` to reduce exposure.
- `ec2_enabled` — set to `false` to skip creating the instance.

Retrieve the connection details after `terraform apply`:

```bash
terraform output ec2_instance_public_dns
terraform output -json ec2_ssh_accounts   # usernames + passwords (sensitive)
```

The instance is reported by its AWS-assigned public DNS name; no named DNS zone
is created. The instance role also enables AWS SSM Session Manager as a key-less
access path.

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
