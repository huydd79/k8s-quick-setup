#!/bin/bash
# -----------------------------------------------------------------------------
# Cleanup Prometheus, Grafana & Ingress
# -----------------------------------------------------------------------------
# Load configuration and check readiness
source ./00.configure.sh
check_ready

echo -e "${RED}--- 🗑️  Cleaning up Monitoring Stack (Prometheus/Grafana) ---${NC}"

echo -e "${BLUE}## 1. Removing Ingress...${NC}"
kubectl delete -f yaml/grafana-ingress.yaml --ignore-not-found

echo -e "${BLUE}## 2. Uninstalling Helm release...${NC}"
helm uninstall monitoring -n monitoring

echo -e "${BLUE}## 3. Deleting namespace and persistent volumes...${NC}"
kubectl delete namespace monitoring --ignore-not-found
kubectl delete pvc --all -n monitoring --ignore-not-found

echo -e "${BLUE}## 4. Cleaning up Prometheus CRDs...${NC}"
kubectl get crd | grep "coreos.com" | awk '{print $1}' | xargs -r kubectl delete crd

echo -e "\n${GREEN}--- ✅ Cleanup Finished ---${NC}"
read