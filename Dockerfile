ARG VICTORIA_METRICS_TAG=v1.118.0
ARG VICTORIA_LOGS_TAG=v1.22.2-victorialogs

FROM victoriametrics/victoria-metrics:${VICTORIA_METRICS_TAG} AS metrics
FROM victoriametrics/victoria-logs:${VICTORIA_LOGS_TAG} AS logs

FROM victoriametrics/victoria-metrics AS metrics
FROM victoriametrics/victoria-logs AS logs
FROM timberio/vector:latest-distroless-static AS vector
FROM grafana/grafana-oss:main
COPY --link --from=metrics /victoria-metrics-prod /
COPY --link --from=logs /victoria-logs-prod /
COPY --link --from=vector /usr/local/bin/vector /usr/local/bin/
RUN grafana cli plugins install victoriametrics-logs-datasource && \
    grafana cli plugins install victoriametrics-metrics-datasource
COPY vector.yaml /etc/vector/
COPY start.sh /
COPY vector.sh /
COPY dashboards/grafana/ /var/lib/grafana-dashboards/
COPY datasources.yml /etc/grafana/provisioning/datasources/
COPY dashboards.yml /etc/grafana/provisioning/dashboards/
COPY grafana.ini /etc/grafana/

USER root
RUN apk add --no-cache jq
WORKDIR /
ENTRYPOINT []
ENV GF_PATHS_DATA=/data/grafana
LABEL maintainer="fly.io"
LABEL org.opencontainers.image.source="https://github.com/superfly/fly-telemetry"
CMD ["/start.sh"]
