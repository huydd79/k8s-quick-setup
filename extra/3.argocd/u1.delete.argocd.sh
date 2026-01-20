#!/bin/bash
# -----------------------------------------------------------------------------
# Huy Do huy.do@cyberark.com
# Date: 2024-06-10
# -----------------------------------------------------------------------------
# Cleanup Script - Deletes ArgoCD, Ingress and all related resources
# -----------------------------------------------------------------------------

CONFIG_FILE="./00.config.sh"

# --- Check if config file exists ---
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "\033[31mError: Configuration file '$CONFIG_FILE' not found!\033[0m"
    exit 1
fi

# --- Import configuration ---
source "$CONFIG_FILE"
check_ready

# --- Confirmation ---
echo -e "${RED}Warning: This will delete ArgoCD, Ingress, and ALL Applications!${NC}"
read -p "Are you sure you want to proceed? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Operation cancelled.${NC}"
    exit 1
fi

echo -e "${BLUE}Step 1: Deleting ArgoCD Ingress...${NC}"
kubectl delete ingress argocd-server-ingress -n $ARGOCD_NAMESPACE --ignore-not-found

echo -e "${BLUE}Step 2: Deleting ArgoCD Applications (GitOps Apps)...${NC}"
# Xóa các App trước để tránh treo Namespace
kubectl get applications -n $ARGOCD_NAMESPACE -o name | xargs -r kubectl delete -n $ARGOCD_NAMESPACE --timeout=30s

echo -e "${BLUE}Step 3: Uninstalling ArgoCD Core Components...${NC}"
kubectl delete -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/$ARGOCD_VERSION/manifests/install.yaml --ignore-not-found

echo -e "${BLUE}Step 4: Cleaning up Custom Resource Definitions (CRDs)...${NC}"
kubectl get crd -o name | grep "argoproj.io" | xargs -r kubectl delete --timeout=30s

echo -e "${BLUE}Step 5: Deleting Namespace...${NC}"
kubectl delete namespace $ARGOCD_NAMESPACE --ignore-not-found

echo -e "${GREEN}Cleanup completed successfully! Cluster is clean.${NC}"