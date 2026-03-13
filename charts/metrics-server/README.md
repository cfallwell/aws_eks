# Metrics Server

This chart wraps the upstream `metrics-server` chart for use with Argo CD in this repository.

## Usage

```bash
helm dependency build charts/metrics-server
helm template metrics-server charts/metrics-server \
  -f charts/metrics-server/values.yaml
```
