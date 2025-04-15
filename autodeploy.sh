#!/bin/bash
set -e

BASE_DIR=$(pwd)

# Step 1: Clean up
echo "[*] Cleaning up old files and containers..."
docker compose down -v || true
docker rm -f prometheus loki grafana node-exporter cadvisor promtail || true
rm -rf "$BASE_DIR/config" "$BASE_DIR/data"

# Step 2: Create directories
mkdir -p "$BASE_DIR/config/prometheus"
mkdir -p "$BASE_DIR/config/loki"
mkdir -p "$BASE_DIR/config/promtail"
mkdir -p "$BASE_DIR/config/grafana/provisioning/datasources"
mkdir -p "$BASE_DIR/config/grafana/provisioning/dashboards"

# Step 3: Prometheus config
cat > "$BASE_DIR/config/prometheus/prometheus.yml" <<EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
EOF

# Step 4: Loki config (no WAL)
cat > "$BASE_DIR/config/loki/config.yaml" <<EOF
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    final_sleep: 0s
  chunk_idle_period: 1h
  chunk_retain_period: 24h

schema_config:
  configs:
    - from: 2020-10-24
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h

storage_config:
  tsdb_shipper:
    active_index_directory: /tmp/loki/index
    cache_location: /tmp/loki/cache
  filesystem:
    directory: /tmp/loki/chunks

compactor:
  working_directory: /tmp/loki/compact

limits_config:
  allow_structured_metadata: true
EOF

# Step 5: Promtail config
cat > "$BASE_DIR/config/promtail/config.yaml" <<EOF
server:
  http_listen_port: 9080
  grpc_listen_port: 0

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: docker_logs
    static_configs:
      - targets: ['localhost']
        labels:
          job: docker-logs
          __path__: /var/lib/docker/containers/*/*.log
    pipeline_stages:
      - docker: {}
      - json:
          expressions:
            jobid: jobid
            taskid: taskid
            statusid: statusid
      - labels:
          jobid:
          taskid:
          statusid:
EOF

# Step 6: Grafana datasources
cat > "$BASE_DIR/config/grafana/provisioning/datasources/datasources.yaml" <<EOF
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    url: http://prometheus:9090
    access: proxy
    isDefault: true

  - name: Loki
    type: loki
    url: http://loki:3100
    access: proxy
EOF

# Step 7: Grafana dashboards provisioning
cat > "$BASE_DIR/config/grafana/provisioning/dashboards/dashboards.yaml" <<EOF
apiVersion: 1
providers:
  - name: default
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    editable: true
    options:
      path: /etc/grafana/provisioning/dashboards
EOF

# Step 8: Loki log filter dashboard
cat > "$BASE_DIR/config/grafana/provisioning/dashboards/loki-log-filter.json" <<EOF
{
  "title": "Loki Job/Task Logs",
  "uid": "loki-logs-filter",
  "panels": [
    {
      "type": "logs",
      "title": "Logs by Job/Task/Status ID",
      "datasource": "Loki",
      "targets": [
        {
          "expr": "{job=\"docker-logs\", jobid=\"$jobid\", taskid=\"$taskid\", statusid=\"$statusid\"}",
          "refId": "A"
        }
      ],
      "gridPos": {"h": 12, "w": 24, "x": 0, "y": 0},
      "options": {"showLabels": true, "wrapLogMessage": true, "showTime": true}
    }
  ],
  "templating": {
    "list": [
      {
        "name": "jobid",
        "label": "Job ID",
        "type": "query",
        "datasource": "Loki",
        "query": "label_values(jobid)",
        "refresh": 1
      },
      {
        "name": "taskid",
        "label": "Task ID",
        "type": "query",
        "datasource": "Loki",
        "query": "label_values(taskid)",
        "refresh": 1
      },
      {
        "name": "statusid",
        "label": "Status ID",
        "type": "query",
        "datasource": "Loki",
        "query": "label_values(statusid)",
        "refresh": 1
      }
    ]
  },
  "time": {"from": "now-6h", "to": "now"},
  "schemaVersion": 37
}
EOF

# Step 9: docker-compose.yml
cat > "$BASE_DIR/docker-compose.yml" <<EOF
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./config/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"
    restart: unless-stopped

  loki:
    image: grafana/loki:latest
    container_name: loki
    user: "root"
    volumes:
      - ./config/loki/config.yaml:/etc/loki/local-config.yaml
    ports:
      - "3100:3100"
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    volumes:
      - ./config/grafana/provisioning:/etc/grafana/provisioning
    ports:
      - "3003:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_SERVER_ROOT_URL=http://localhost:3003
    restart: unless-stopped

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "9100:9100"
    restart: unless-stopped

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    restart: unless-stopped

  promtail:
    image: grafana/promtail:latest
    container_name: promtail
    volumes:
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock
      - ./config/promtail/config.yaml:/etc/promtail/config.yaml
    command: -config.file=/etc/promtail/config.yaml
    restart: unless-stopped
EOF

# Step 10: Run everything
echo "[*] Starting the stack..."
docker compose up -d

echo "[*] Done! Access Grafana at: http://localhost:3003 (admin/admin)"
echo "Import Linux Dashboard 19937 from Grafana.com if not auto-loaded."
echo "You can view system metrics and filter logs by jobid/taskid/statusid."

