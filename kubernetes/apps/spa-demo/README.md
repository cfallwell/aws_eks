# SPA Demo

`spa-demo` is a GitOps-delivered demo application with:

- a React SPA frontend
- a Node.js API layer
- a PostgreSQL backend on Amazon RDS
- ALB ingress, IRSA-backed S3 access, and an EBS-backed PVC on EKS

## Local workflow

```bash
cd kubernetes/apps/spa-demo
npm install
npm run build
```

The build produces:

- `dist/` for local preview and Node runtime assets
- `deploy/base/site/` for Flux/Kustomize SPA payloads
- `deploy/base/runtime/` for the bundled Node server payload

At deploy time, an init container assembles the runtime from the committed payloads before the app container starts.
