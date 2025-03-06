# Fly Data Shipper

Consume logs+metrics from the Fly.io-provided NATS streams on `[fdaa::3]:4223`.
Send logs to local VictoriaLogs, metrics to local VictoriaMetrics, and both to S3 for long-term archival.
Also run a local Grafana instance with data sources and dashboards all hooked up and ready to go.

This is a simple, lightweight reference implementation for quick, out-of-the-box observability
for simple deployments on Fly.io. It runs in a single monolithic instance.
You can vertically scale this deployment for small-to-medium sized orgs. Once you grow out of this setup, you can fork and modify
this template to further extend it yourself, or ship data directly to managed services that can offer greater scale and support.

## Security

The app doesn't configure any authentication, it's a simple template for internal use on a secure private network.
**Do not deploy this app with a public IP without setting up authentication!**

Grafana is configured for anonymous admin access, which you can reach on its default port 3000 over 6pn,
or on port 80 through Flycast. Set up a persistent Wireguard tunnel to your org's network
and access `${FLY_APP_NAME}.flycast`. `${FLY_APP_NAME}.internal:3000`, or run `fly proxy 3000` and access `localhost:3000`.

## High Availability

You can run this app in a simple High-Availability mode by scaling up to multiple Machines, in the same or different region.
Each instance separately ingests the NATS streams into its own local storage, and Flycast will load-balance service
requests to the nearest available instance. Grafana is configured to use the High Availability Alertmanager
implementation that suppresses duplicate alert notifications across the cluster.
Each Grafana instance uses its own local SQLite database by default. You must change this config to use
a shared external database cluster (like Postgres), or for a more minimal approach, use only file-provisioned
dashboards, alert rules, etc., so all state is consistently maintained across both Grafana instances.

Required env variables (provide with `fly secrets set`, or modify `fly.toml`):

* `ACCESS_TOKEN` (`fly secrets set ACCESS_TOKEN=$(fly tokens create readonly)`)
* `BUCKET_NAME`
* `AWS_REGION`
* `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`, or AWS credentials through another provider
* `ORG` (default `personal`)
