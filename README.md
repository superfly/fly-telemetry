# Fly Data Shipper

Consume logs+metrics from the Fly.io-provided NATS streams on `[fdaa::3]:4223`.
Send logs to local VictoriaLogs, metrics to local VictoriaMetrics, and both to S3 for long-term archival.
Also run a local Grafana instance with data sources and dashboards all hooked up and ready to go.

This is a simple, lightweight reference implementation for quick, out-of-the-box observability
for simple deployments on Fly.io. It runs in a single monolithic instance without any High Availability
clustering set up. You can vertically scale this deployment as-is, but once you grow out of
this setup you're welcome to fork and modify this template to extend it yourself, or ship data directly
to managed services that can offer better support.

The app doesn't implement any authentication, and doesn't expose any public services by default.
Grafana is configured for anonymous admin access, which you can reach on its default port 3000 over 6pn.
Run `fly proxy 3000`, or set up a persistent Wireguard tunnel to your org's network.

Required env variables (provide with `fly secrets set`, or modify `fly.toml`):

* `ACCESS_TOKEN` (`fly secrets set ACCESS_TOKEN=$(fly tokens create readonly)`)
* `BUCKET_NAME`
* `AWS_REGION`
* `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`, or AWS credentials through another provider
* `ORG` (default `personal`)
