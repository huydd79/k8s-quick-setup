#!/bin/bash
# -----------------------------------------------------------------------------
# Huy Do huy.do@cyberark.com
# u3.delete.repo.sh - Xóa cấu hình kết nối Repository
# -----------------------------------------------------------------------------
source ./00.config.sh

echo -e "${BLUE}Dọn dẹp cấu hình Repository...${NC}"

# Xóa Secret chứa Token
kubectl delete secret gitlab-repo-creds -n $ARGOCD_NAMESPACE --ignore-not-found

echo -e "${GREEN}Đã xóa Secret gitlab-repo-creds.${NC}"