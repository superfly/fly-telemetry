# Fly Data Shipper

- `src` consumes org logs+metrics from NATS to a local disk buffer and forwards to `dest`.
- `data` sends logs to local VictoriaLogs, metrics to local VictoriaMetrics, and both to object storage for long-term archival.
- `grafana` runs a local Grafana instance, with data sources properly configured.

Required env variables (provide with `fly secrets set`, or modify `fly.toml`):

* `ACCESS_TOKEN` (`fly secrets set ACCESS_TOKEN=$(fly tokens create readonly)`)
* `BUCKET_NAME`
* `AWS_REGION`
* `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`, or AWS credentials through another provider
* `ORG` (default `personal`)
