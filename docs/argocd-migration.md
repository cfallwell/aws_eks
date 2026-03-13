# Argo CD Runbook

This repository now uses `Argo CD + Helm` for application delivery into EKS.

## What This Repository Automates

- Installs Argo CD with Terraform.
- Installs the AWS Load Balancer Controller with Terraform.
- Creates the `gp3` `StorageClass` with Terraform.
- Bootstraps an Argo CD `Application` that deploys `metrics-server` into `kube-system`.
- Creates the `spa-demo` namespace and `spa-demo-db` secret with Terraform.
- Bootstraps an Argo CD `Application` that deploys `spa-demo` from `charts/spa-demo`.

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

1. Update the source under `apps/spa-demo`.
2. Run `npm run build` from `apps/spa-demo` to refresh the chart payload in `charts/spa-demo/files`.
3. Commit and push the branch Argo CD is watching.
4. Let Argo CD sync automatically or trigger a manual sync in the UI.
