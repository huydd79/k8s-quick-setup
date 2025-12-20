# Kubernetes Automation Setup Scripts (RHEL 9 / Proxmox)

This repository provides a professional-grade automation suite to deploy and manage a Kubernetes cluster using **CRI-O** as the container runtime. The suite is fully integrated with Ingress (Traefik), Monitoring (Prometheus/Grafana), and the official K8s Dashboard.

## 🏗️ Infrastructure Environment
* **Operating System**: Red Hat Enterprise Linux (RHEL) 9.
* **Hypervisor**: Proxmox VE 9.1.2.
* **Deployment Type**: Virtual Machines (VMs).
* **Last Verified Test**: December 20, 2025.

---

## 📂 Project Structure
* **Root Directory**: Contains all automation shell scripts (`.sh`).
* **yaml/**: Stores static and dynamic Kubernetes manifests.
* **00.configure.sh**: The central configuration file for all global variables.

---

## 🛠️ Getting Started (Prerequisites)

Before running any installation, you **must** configure your environment:

1.  Edit **`00.configure.sh`**.
2.  Update `DOMAIN_SUFFIX` (e.g., `k8s.yourdomain.com`) and `POD_CIDR`.
3.  Change `READY=false` to **`READY=true`**.

*Note: All scripts include a safety check and will refuse to execute if `READY` is set to false.*

---

## 🚀 Installation Roadmap

Execute scripts in numerical order for a complete setup:

### 1. Core Infrastructure
1.  **`01.installing.crio.sh`**: Installs CRI-O runtime and K8s components (`kubeadm`, `kubectl`, `kubelet`).
2.  **`02.setup.master.sh`**: Initializes the Control Plane and deploys Calico CNI using your configured `POD_CIDR`.
3.  **`03.setup.worker.sh`**: Removes the Master Taint, allowing the node to host both Control Plane and Worker workloads.

### 2. Services & UI
4.  **`04.setup.dashboard.sh`**: Deploys the official K8s Dashboard.
5.  **`05.setup.traefik.sh`**: Installs Traefik Ingress Controller and secures the Web UI with Basic Auth.
6.  **`06.change.traefik.auth.sh`**: Interactive tool to rotate Traefik dashboard credentials.

### 3. Monitoring & Observability
7.  **`07.setup.metric.server.sh`**: Deploys Metrics Server (v0.8.0) to enable resource monitoring via `kubectl top`.
8.  **`08.setup.grafana.sh`**: Installs Prometheus and Grafana for historical data visualization.

---

## 🧹 Cleanup Scripts
Reset specific components or the entire cluster using the `u` prefixed scripts:
* **`u1.cleanup.crio.sh`**: Purges all K8s/CRI-O packages and configurations.
* **`u2.cleanup.master.sh`**: Resets the cluster initialization state.
* **`u5.cleanup.traefik.sh`**: Uninstalls Traefik and its namespace.
* **`u8.cleanup.grafana.sh`**: Removes the monitoring stack and all persistent data (PVCs).

---

## 🔐 Access Information
*Credentials and URLs are based on your `00.configure.sh` settings.*

| Service | URL | Default Credentials |
| :--- | :--- | :--- |
| **K8s Dashboard** | `https://master.${DOMAIN_SUFFIX}` | Use `zz.get.dashboard.token.sh` |
| **Traefik UI** | `https://traefik.${DOMAIN_SUFFIX}/dashboard/` | `admin` / `admin123` |
| **Grafana** | `https://grafana.${DOMAIN_SUFFIX}` | `admin` / `admin` (change on first login) |

---

## 📝 Important Notes
* **Permissions**: Must be executed as `root`.
* **SSL**: Certificates are self-signed. Browser warnings are expected; select "Advanced" -> "Proceed".
* **Metrics**: Metrics Server uses `--kubelet-insecure-tls` for local lab compatibility.