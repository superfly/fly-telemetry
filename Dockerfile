FROM victoriametrics/victoria-metrics AS metrics
FROM victoriametrics/victoria-logs AS logs
FROM timberio/vector:latest-distroless-static AS vector
FROM grafana/grafana:latest
COPY --link --from=metrics /victoria-metrics-prod /
COPY --link --from=logs /victoria-logs-prod /
COPY --link --from=vector /usr/local/bin/vector /usr/local/bin/

COPY vector-*.yml /
COPY start.sh /
USER root
WORKDIR /
ENTRYPOINT []
