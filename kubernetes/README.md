# Kubernetes

This tree contains the GitOps-managed cluster state for EKS.

## Active Sections

- `charts/`: Helm charts reconciled by Argo CD.
- `flux/`: legacy Flux sources and Kustomizations retained during migration.
- `apps/kube-system/`: EKS platform add-ons and storage primitives.
- `apps/monitoring/`: Splunk OpenTelemetry base plus overlay values.
- `apps/spa-demo/`: app source and deployment manifests.
