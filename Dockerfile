FROM victoriametrics/victoria-metrics AS metrics
FROM victoriametrics/victoria-logs AS logs
FROM timberio/vector:latest-distroless-static AS vector
FROM flyio/grafana-oss:dev
COPY --link --from=metrics /victoria-metrics-prod /
COPY --link --from=logs /victoria-logs-prod /
COPY --link --from=vector /usr/local/bin/vector /usr/local/bin/
RUN grafana cli plugins install victoriametrics-logs-datasource && \
    grafana cli plugins install victoriametrics-metrics-datasource

COPY vector.yaml /etc/vector/
COPY start.sh /
COPY dashboards/grafana/ /var/lib/grafana-dashboards/
COPY datasources.yml /etc/grafana/provisioning/datasources/
COPY dashboards.yml /etc/grafana/provisioning/dashboards/
COPY grafana.ini /etc/grafana/

USER root
WORKDIR /
ENTRYPOINT []
CMD ["/start.sh"]
