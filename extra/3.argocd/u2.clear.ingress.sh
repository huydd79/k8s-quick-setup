#!/bin/bash
# -----------------------------------------------------------------------------
# Huy Do huy.do@cyberark.com
# u2.delete.ingress.sh - Dọn dẹp sạch sẽ cấu hình Network của ArgoCD
# -----------------------------------------------------------------------------

# --- Import configuration ---
CONFIG_FILE="./00.config.sh"
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "\033[31mError: Configuration file '$CONFIG_FILE' not found!\033[0m"
    exit 1
fi
source "$CONFIG_FILE"

echo -e "${BLUE}Starting cleanup for ArgoCD Ingress and Traefik resources...${NC}"

# 1. Xóa Ingress chuẩn
echo -e "${YELLOW}Deleting Standard Ingress...${NC}"
kubectl delete ingress argocd-server-ingress -n $ARGOCD_NAMESPACE --ignore-not-found

# 2. Xóa Traefik IngressRoute (nếu có)
echo -e "${YELLOW}Deleting Traefik IngressRoutes...${NC}"
kubectl delete ingressroute argocd-server -n $ARGOCD_NAMESPACE --ignore-not-found
kubectl delete ingressroute argocd-server-route -n $ARGOCD_NAMESPACE --ignore-not-found

# 3. Xóa Middleware
echo -e "${YELLOW}Deleting Traefik Middlewares...${NC}"
kubectl delete middleware argocd-headers -n $ARGOCD_NAMESPACE --ignore-not-found

echo -e "${GREEN}Cleanup complete! Your network configuration for ArgoCD is now empty.${NC}"