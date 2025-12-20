#!/bin/bash
# -----------------------------------------------------------------------------
# Traefik Cleanup Script
# Script: u5.cleanup.traefik.sh
# Purpose: Completely remove Traefik resources and namespace
# -----------------------------------------------------------------------------

# Load configuration and check readiness
source ./00.configure.sh
check_ready

NAMESPACE="traefik-v2"
ROUTE_YAML="yaml/traefik-dashboard.yaml"

echo -e "${RED}--- 🗑️  Starting Traefik Cleanup ---${NC}"

# 1. Remove Kubernetes resources from the YAML file
echo -e "${BLUE}## 1. Deleting IngressRoutes and Middlewares...${NC}"
if [ -f "$ROUTE_YAML" ]; then
    kubectl delete -f "$ROUTE_YAML" --ignore-not-found
fi

# 2. Uninstall the Helm release
echo -e "${BLUE}## 2. Uninstalling Traefik via Helm...${NC}"
if helm list -n $NAMESPACE | grep -q "traefik"; then
    helm uninstall traefik -n $NAMESPACE
else
    echo -e "No Helm release found."
fi

# 3. Delete the Secret and Namespace
echo -e "${BLUE}## 3. Deleting Secret and Namespace...${NC}"
kubectl -n $NAMESPACE delete secret traefik-dashboard-auth --ignore-not-found

# Force delete the namespace to ensure a clean state
echo -e "${BLUE}## 4. Removing namespace: $NAMESPACE${NC}"
kubectl delete namespace $NAMESPACE --ignore-not-found

# 4. Final Verification
echo -e "\n${GREEN}--- ✅ Cleanup Finished ---${NC}"
echo -e "Current namespaces:"
kubectl get ns | grep $NAMESPACE || echo -e "Namespace $NAMESPACE is gone."

echo -e "\nPress ENTER to finish."
read