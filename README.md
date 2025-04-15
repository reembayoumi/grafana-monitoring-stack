# 🛠️ Grafana Monitoring Stack (Prometheus + Loki + cAdvisor + Node Exporter + Promtail)

A plug-and-play monitoring stack to track system metrics, Docker container performance, and structured log data. Easily filter logs by `jobid`, `taskid`, and `statusid` straight from Grafana dashboards.

---

## 📦 Components Included

- **Grafana** (visualization)
- **Prometheus** (metrics collection)
- **Loki** (log aggregation)
- **Promtail** (log shipping)
- **cAdvisor** (Docker metrics)
- **Node Exporter** (Linux system metrics)

---

## 🚀 Features

- 📊 Real-time dashboards for:
  - Linux system (CPU, memory, disk, load, network)
  - Docker container usage (via cAdvisor)
  - Live logs filterable by job/task/status IDs
- 🔍 Log search with custom labels parsed from structured logs
- 🧪 Auto-deploy script to spin up everything via Docker Compose
- 💨 Fast setup, low overhead, ideal for VPS or dev/test environments

---

## ⚙️ Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/grafana-monitoring-stack.git
cd grafana-monitoring-stack

