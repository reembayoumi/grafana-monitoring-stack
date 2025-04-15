🚀 Usage
This monitoring stack is built using Docker Compose and includes Prometheus, Grafana, Loki, cAdvisor, Promtail, and Node Exporter.

🐳 Requirements
Docker

Docker Compose

🔧 Run the stack
bash
Copy
Edit
git clone https://github.com/reembayoumi/grafana-monitoring-stack.git
cd grafana-monitoring-stack
chmod +x setup.sh
./setup.sh
Wait a few seconds for everything to start...

Then access:

Grafana: http://localhost:3003
→ Login: admin / admin

Prometheus: http://localhost:9090

Node Exporter: http://localhost:9100

cAdvisor: http://localhost:8080

📊 Dashboards
Includes dashboards for:

System metrics

Docker containers

Logs filtered by jobId, taskId, and statusId via Loki

Would you like me to generate a polished README.md for your repo with badges, description, and all sections?







You said:
yes olsiehd readme yes


ChatGPT said:
Awesome! Here's a polished README.md you can drop into your repo grafana-monitoring-stack:

markdown
Copy
Edit
# 📊 Grafana Monitoring Stack with Logs & Metrics

A fully automated observability stack using **Prometheus**, **Grafana**, **Loki**, **Promtail**, **cAdvisor**, and **Node Exporter** — with out-of-the-box dashboards for system stats, Docker containers, and log filtering by `jobId`, `taskId`, and `statusId`.

![Grafana Screenshot](https://raw.githubusercontent.com/reembayoumi/grafana-monitoring-stack/main/docs/preview.png)

---

## ⚙️ Features

- ✅ System metrics (CPU, memory, disk, network)
- ✅ Docker container metrics (via cAdvisor)
- ✅ Centralized logs with structured filtering (via Loki & Promtail)
- ✅ Filter logs by `jobId`, `taskId`, `statusId`
- ✅ Auto-provisioned dashboards
- ✅ One-command startup with `setup.sh`

---

## 🐳 Requirements

- Docker
- Docker Compose

---

## 🚀 Setup & Run

```bash
git clone https://github.com/reembayoumi/grafana-monitoring-stack.git
cd grafana-monitoring-stack
chmod +x setup.sh
./setup.sh
Wait a few seconds... then access:


Service	URL	Notes
Grafana	http://localhost:3003	Login: admin/admin
Prometheus	http://localhost:9090	
Loki	http://localhost:3100	
Node Exporter	http://localhost:9100	
cAdvisor	http://localhost:8080	
📊 Dashboards Included
✅ System Monitoring (Linux server overview)

✅ Docker Monitoring (cAdvisor + metrics)

✅ Logs Explorer – with dropdown filters:

jobId

taskId

statusId

🧠 Architecture
mermaid
Copy
Edit
graph TD
  subgraph Monitoring Stack
    Prometheus --> Grafana
    Loki --> Grafana
    NodeExporter --> Prometheus
    cAdvisor --> Prometheus
    Promtail --> Loki
  end

  DockerLogs --> Promtail
📂 File Structure
arduino
Copy
Edit
grafana-monitoring-stack/
├── config/
│   ├── prometheus/
│   ├── loki/
│   ├── promtail/
│   └── grafana/
├── data/
├── docker-compose.yml
└── setup.sh
🤝 Contributions
Feel free to fork or improve the dashboards and config! PRs are welcome.

🐣 Disclaimer


Built with care for devs and sysadmins who want fast, clean monitoring setups.

All configurations and dashboards were handcrafted, tested, and optimized for practical use. ❤️


yaml
Copy
Edit

---










Search

Reason



