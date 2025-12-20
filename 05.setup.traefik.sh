#!/bin/bash
# -----------------------------------------------------------------------------
# Traefik Ingress Controller & Routing Setup (Auto-install Helm)
# Script: 05.setup.traefik.sh
# -----------------------------------------------------------------------------

# Load configuration and check readiness
source ./00.configure.sh
check_ready

NAMESPACE="traefik-v2"
TRAEFIK_YAML="yaml/traefik-dashboard.yaml"
KUBE_DASH_YAML="yaml/kube-dashboard-traefik.yaml"

echo -e "${GREEN}--- 🚀 Deploying Traefik Ingress Controller ---${NC}"

# --- Part 0: Check and Install Helm ---
if ! command -v helm &> /dev/null; then
    echo -e "${YELLOW}>> Helm not found. Attempting to install Helm automatically...${NC}"
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}ERROR: Automatic Helm installation failed!${NC}"
        echo -e "${YELLOW}Please install Helm manually: https://helm.sh/docs/intro/install/${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Helm installed successfully.${NC}"
fi

# Add Traefik Repo if not exists
echo -e "${BLUE}## Updating Helm repositories...${NC}"
helm repo add traefik https://traefik.github.io/charts &> /dev/null
helm repo update &> /dev/null

# --- Part 1: Install Traefik via Helm ---
echo -e "${BLUE}## 1. Installing/Upgrading Traefik via Helm...${NC}"
helm upgrade --install traefik traefik/traefik \
  --namespace $NAMESPACE --create-namespace \
  --set ports.web.nodePort=31080 \
  --set ports.websecure.nodePort=31443 \
  --set service.type=NodePort \
  --set dashboard.enabled=true

# Wait for Traefik Pod and CRDs
echo -e "${YELLOW}Waiting for Traefik Pod to initialize (90s)...${NC}"
sleep 15 # Wait for CRDs to register
kubectl wait --namespace $NAMESPACE \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=traefik \
  --timeout=90s

# --- Part 2: Configure Dynamic Routing ---
echo -e "\n${BLUE}## 2. Configuring Ingress Routes (Dynamic Domain Injection)...${NC}"

# 2.1 Traefik Dashboard
if [ -f "$TRAEFIK_YAML" ]; then
    echo -e "${YELLOW}>> Enabling Traefik UI Route for: traefik.${DOMAIN_SUFFIX}${NC}"
    sed "s|\${DOMAIN_SUFFIX}|${DOMAIN_SUFFIX}|g" "$TRAEFIK_YAML" > "${TRAEFIK_YAML}.tmp"
    kubectl apply -f "${TRAEFIK_YAML}.tmp"
    rm "${TRAEFIK_YAML}.tmp"
fi

# 2.2 K8s Dashboard
if [ -f "$KUBE_DASH_YAML" ]; then
    echo -e "${YELLOW}>> Enabling K8s Dashboard Route for: master.${DOMAIN_SUFFIX}${NC}"
    sed "s|\${DOMAIN_SUFFIX}|${DOMAIN_SUFFIX}|g" "$KUBE_DASH_YAML" > "${KUBE_DASH_YAML}.tmp"
    kubectl apply -f "${KUBE_DASH_YAML}.tmp"
    rm "${KUBE_DASH_YAML}.tmp"
fi

# --- Part 3: Summary ---
echo -e "\n${GREEN}--- ✅ Traefik Gateway & Routing Deployment Complete ---${NC}"
echo -e "1. Traefik Dashboard: https://traefik.${DOMAIN_SUFFIX}/dashboard/"
echo -e "2. K8s Dashboard:     https://master.${DOMAIN_SUFFIX}"
echo -e "\nPress ENTER to finish."
read