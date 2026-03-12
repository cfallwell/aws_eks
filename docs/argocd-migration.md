# Argo CD Migration Runbook

This repository now defaults to `Argo CD + Helm` for application delivery into EKS. The migration in this branch is intentionally staged.

## What This Branch Automates

- Installs Argo CD with Terraform.
- Installs the AWS Load Balancer Controller with Terraform.
- Creates the `gp3` `StorageClass` with Terraform.
- Creates the `spa-demo` namespace and `spa-demo-db` secret with Terraform.
- Bootstraps an Argo CD `Application` that deploys `spa-demo` from `kubernetes/charts/spa-demo`.

## What Is Still Legacy

- `kubernetes/flux/**`
- Flux `HelmRelease`, `GitRepository`, and `Kustomization` objects under `kubernetes/apps/**`
- Monitoring and other platform add-ons that still depend on Flux CRDs

Do not remove Flux from a live cluster until those remaining workloads are migrated.

## Prerequisites

You need these tools locally:

- `terraform`
- `aws`
- `kubectl`
- `helm`

You also need:

- AWS credentials with permissions for EKS, IAM, EC2, VPC, RDS, and S3
- access to the Git repository URL you set in Terraform

## Initial Deploy

1. Copy the example variables.

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars`.

Set at minimum:

- `region`
- `public_access_cidrs`
- `gitops_repository_url`
- `gitops_repository_branch`
- `spa_demo_host` if you want a DNS host on the ALB ingress
- Splunk variables only if you still plan to migrate those monitoring components later

3. Initialize and apply Terraform.

```bash
terraform init
terraform apply
```

4. Configure kubeconfig using the Terraform output.

```bash
aws eks update-kubeconfig --region <your-region> --name <your-cluster-name>
```

5. Port-forward the Argo CD UI.

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:80
```

6. Retrieve the initial Argo CD admin password.

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d && echo
```

7. Log in to Argo CD.

- URL: `http://localhost:8080`
- Username: `admin`
- Password: value from the previous command

8. Verify the application sync.

```bash
kubectl -n argocd get applications
kubectl -n spa-demo get pods,svc,ingress,pvc,secret
```

## Image and App Updates

The current chart packages the `spa-demo` runtime and static files directly from this repository.

When you change the app:

1. Update the assets under `kubernetes/apps/spa-demo/deploy/base`.
2. Copy the updated runtime and site payload into `kubernetes/charts/spa-demo/files`.
3. Commit and push the branch Argo CD is watching.
4. Let Argo CD sync automatically or trigger a manual sync in the UI.

## Remaining Migration Work

Migrate the remaining Flux-managed add-ons in this order:

1. Convert each Flux `HelmRelease` to either a Terraform `helm_release` or an Argo CD `Application`.
2. Replace Flux `Kustomization` resources with Argo CD `Application` or `ApplicationSet` objects.
3. Move cluster-specific secrets out of Git and into AWS Secrets Manager plus External Secrets.
4. Remove Flux bootstrap from Terraform only after every Flux CRD-backed workload is gone.

## Final Flux Removal

Only perform these steps after you have migrated every remaining Flux-managed workload:

1. Set `gitops_controller = "argocd"` in `terraform.tfvars`.
2. Remove or archive the remaining `kubernetes/flux` content.
3. Delete Flux resources from the cluster.

```bash
kubectl delete namespace flux-system --ignore-not-found
kubectl get crd | grep fluxcd.io
```

4. Re-run Terraform to confirm Flux is no longer managed.

```bash
terraform apply
```

5. Confirm no Flux CRDs or workloads remain.

```bash
kubectl get applications -n argocd
kubectl get all -A | grep flux
```
