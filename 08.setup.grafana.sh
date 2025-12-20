#!/bin/bash
source ./00.configure.sh
check_ready

echo -e "${GREEN}--- 📊 Installing Monitoring Stack ---${NC}"

# 1. Helm Install
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set grafana.adminPassword=admin
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false

# 2. Apply Dynamic Ingress
echo -e "${BLUE}## Applying Grafana Ingress for ${DOMAIN_SUFFIX}...${NC}"
INGRESS_YAML="yaml/grafana-ingress.yaml"
if [ -f "$INGRESS_YAML" ]; then
    sed "s|\${DOMAIN_SUFFIX}|${DOMAIN_SUFFIX}|g" "$INGRESS_YAML" > "${INGRESS_YAML}.tmp"
    kubectl apply -f "${INGRESS_YAML}.tmp"
    rm "${INGRESS_YAML}.tmp"
fi

echo -e "\n${GREEN}--- ✅ Grafana Ready ---${NC}"
echo -e "URL: https://grafana.${DOMAIN_SUFFIX}"