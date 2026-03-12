# SignalFx OpenTelemetry

This chart wraps Splunk's upstream `splunk-otel-collector` Helm chart for use in this repository.

## Files

- `values.yaml`: chart settings used by Argo CD and local Helm rendering

Terraform and the Argo CD application supply the deployment-specific cluster name, Splunk realm, Splunk Platform endpoint, and secret name at deploy time.

## Usage

```bash
helm dependency build charts/signalfx-otel
helm template signalfx-otel charts/signalfx-otel \
  -f charts/signalfx-otel/values.yaml
```
