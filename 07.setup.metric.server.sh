#!/bin/bash
# -----------------------------------------------------------------------------
# Kubernetes Metrics Server Setup - Tailored for v0.8.0
# -----------------------------------------------------------------------------
# Load configuration and check readiness
source ./00.configure.sh
check_ready

echo -e "${GREEN}--- 📈 Starting Metrics Server v0.8.0 Deployment ---${NC}"

LOCAL_YAML="yaml/metrics-server.yaml"

# 1. Check if manifest exists
if [ ! -f "$LOCAL_YAML" ]; then
    echo -e "${BLUE}## Downloading manifest...${NC}"
    mkdir -p yaml
    curl -L -s https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml > $LOCAL_YAML
fi

# 2. Patching manifest
echo -e "${BLUE}## 1. Patching manifest (Targeting port 10250)...${NC}"
# Insert --kubelet-insecure-tls after --secure-port=10250
sed -i '/- --secure-port=10250/a \        - --kubelet-insecure-tls' $LOCAL_YAML

# 3. Apply
echo -e "${BLUE}## 2. Applying to Cluster...${NC}"
kubectl apply -f $LOCAL_YAML

# 4. Force restart Pod
echo -e "${BLUE}## 3. Restarting Pod to ensure new args...${NC}"
kubectl delete pod -n kube-system -l k8s-app=metrics-server --ignore-not-found

# 5. Wait for results
echo -e "\n${YELLOW}Waiting 40s for Metrics Server to scrape data from Kubelets...${NC}"
for i in {1..8}; do echo -n "."; sleep 5; done

echo -e "\n\n${BLUE}## Final Test:${NC}"
kubectl top nodes

echo -e "\nPress ENTER to finish."
read