FROM victoriametrics/victoria-metrics:stable AS metrics
FROM victoriametrics/victoria-logs AS logs
FROM timberio/vector:latest-distroless-static AS vector
FROM prom/alertmanager AS alertmanager
FROM grafana/grafana-oss:main
COPY --link --from=metrics /victoria-metrics-prod /
COPY --link --from=logs /victoria-logs-prod /
COPY --link --from=vector /usr/local/bin/vector /usr/local/bin/
COPY --link --from=alertmanager /bin/alertmanager /bin/

RUN grafana cli plugins install victoriametrics-logs-datasource && \
    grafana cli plugins install victoriametrics-metrics-datasource && \
    grafana cli plugins install grafana-athena-datasource
COPY vector.yaml /etc/vector/
COPY start.sh vector.sh import.sh alertmanager.yml /
COPY config aws.sh /root/.aws/
COPY config aws.sh /usr/share/grafana/.aws/

COPY dashboards/grafana/ /var/lib/grafana-dashboards/
COPY datasources.yml /etc/grafana/provisioning/datasources/
COPY dashboards.yml /etc/grafana/provisioning/dashboards/
COPY grafana.ini /etc/grafana/

USER root
RUN apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
  curl jq s5cmd bash envsubst moreutils
WORKDIR /
ENTRYPOINT []
ENV GF_PATHS_DATA=/data/grafana
LABEL maintainer="fly.io"
LABEL org.opencontainers.image.source="https://github.com/superfly/fly-telemetry"
CMD ["/start.sh"]
