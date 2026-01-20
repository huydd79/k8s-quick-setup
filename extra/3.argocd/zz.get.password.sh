#!/bin/bash
# -----------------------------------------------------------------------------
# Huy Do huy.do@cyberark.com
# 01.install.argocd.sh
# -----------------------------------------------------------------------------
source ./00.config.sh
check_ready

# Lấy mật khẩu admin
ARGOCD_PWD=$(kubectl -n $ARGOCD_NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo -e "${GREEN}ArgoCD installed successfully!${NC}"
echo -e "${YELLOW}Initial Admin Password: ${GREEN}$ARGOCD_PWD${NC}"