#!/bin/bash
# -----------------------------------------------------------------------------
# Metrics Server Cleanup Script
# Script: u7.cleanup.metrics.server.sh
# Purpose: Completely remove Metrics Server resources and configurations
# -----------------------------------------------------------------------------

# Load configuration and check readiness
source ./00.configure.sh
check_ready

LOCAL_YAML="yaml/metrics-server.yaml"

echo -e "${RED}--- 🗑️  Starting Metrics Server Cleanup ---${NC}"

# 1. Remove resources using the local YAML file if it exists
if [ -f "$LOCAL_YAML" ]; then
    echo -e "${BLUE}## 1. Deleting resources from $LOCAL_YAML...${NC}"
    kubectl delete -f "$LOCAL_YAML" --ignore-not-found
else
    echo -e "${YELLOW}Warning: $LOCAL_YAML not found. Proceeding with manual cleanup...${NC}"
fi

# 2. Manual cleanup of specific Metrics Server components 
# (In case the YAML was modified or missing)
echo -e "${BLUE}## 2. Cleaning up specific components...${NC}"
kubectl delete apiservice v1beta1.metrics.k8s.io --ignore-not-found
kubectl delete deployment metrics-server -n kube-system --ignore-not-found
kubectl delete service metrics-server -n kube-system --ignore-not-found
kubectl delete clusterrole system:metrics-server --ignore-not-found
kubectl delete clusterrolebinding system:metrics-server --ignore-not-found
kubectl delete rolebinding metrics-server-auth-reader -n kube-system --ignore-not-found

# 3. Final Verification
echo -e "\n${GREEN}--- ✅ Metrics Server Cleanup Finished ---${NC}"
echo -e "Checking for remaining metrics resources..."
kubectl get pods -n kube-system | grep metrics-server || echo -e "No metrics-server pods found."

echo -e "\nPress ENTER to finish."
read