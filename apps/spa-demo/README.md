# SPA Demo

`spa-demo` is a GitOps-delivered demo application with:

- a React SPA frontend
- a Node.js API layer
- a PostgreSQL backend on Amazon RDS
- ALB ingress, IRSA-backed S3 access, and an EBS-backed PVC on EKS

## Local workflow

```bash
cd apps/spa-demo
npm install
npm run build
```

The build produces:

- `dist/` for local preview and the bundled Node runtime
- `charts/spa-demo/files/` for the committed Helm chart payload

Argo CD deploys the chart from `charts/spa-demo`, and the build syncs the chart payload directly from this app directory.
