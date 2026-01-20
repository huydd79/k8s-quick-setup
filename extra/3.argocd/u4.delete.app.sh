#!/bin/bash
# -----------------------------------------------------------------------------
# Huy Do huy.do@cyberark.com
# u4.delete.app.sh - Xóa ArgoCD Application và các tài nguyên đi kèm
# -----------------------------------------------------------------------------
source ./00.config.sh

# Tên Application bạn đã đặt (nếu bạn đã đổi tên thành webapp02 thì sửa ở đây)
APP_NAME="webapp02"

echo -e "${BLUE}Đang xóa Application: $APP_NAME...${NC}"

# Lệnh xóa Application trong namespace argocd
# Lưu ý: Khi xóa Application, các tài nguyên (Deployment, Service, Ingress) 
# mà nó quản lý trên Cluster cũng sẽ bị xóa theo nếu đã bật tính năng Prune.
kubectl delete application $APP_NAME -n $ARGOCD_NAMESPACE --ignore-not-found

echo -e "${GREEN}Đã dọn dẹp xong Application $APP_NAME.${NC}"