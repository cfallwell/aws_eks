# SignalFx OpenTelemetry

This chart wraps Splunk's upstream `splunk-otel-collector` Helm chart for use in this repository.

## Files

- `values.yaml`: base settings shared across environments
- `overlays/default/values.yaml`: environment override layer

The base values file uses placeholder values for `clusterName` and Splunk credentials so the chart validates cleanly. Replace those values before deploying.

## Usage

```bash
helm dependency build charts/signalfx-otel
helm template signalfx-otel charts/signalfx-otel \
  -f charts/signalfx-otel/values.yaml \
  -f charts/signalfx-otel/overlays/default/values.yaml
```
