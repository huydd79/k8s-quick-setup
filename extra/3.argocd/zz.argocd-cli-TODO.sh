#!/bin/bash
# -----------------------------------------------------------------------------
# Huy Do huy.do@cyberark.com
# 02.setup.ingress.sh - Optimized for Unified Port 8080
# -----------------------------------------------------------------------------
source ./00.config.sh
check_ready

ARGOCD_HOST="argocd.k8s.huydo.net"

echo -e "${BLUE}Applying Ingress for ArgoCD...${NC}"

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: $ARGOCD_NAMESPACE
  annotations:
    # Theo mẫu Grafana bạn đã chạy thành công
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
spec:
  ingressClassName: traefik
  rules:
  - host: $ARGOCD_HOST
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 80
EOF

echo -e "${GREEN}Cấu hình Ingress đã được áp dụng!${NC}"

echo -e "${GREEN}Tải bản thực thi (binary) từ GitHub${NC}"
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

echo -e "${GREEN}Cấp quyền thực thi cho tệp tin${NC}"
chmod +x /usr/local/bin/argocd

echo -e "${GREEN}Kiểm tra phiên bản để xác nhận cài đặt thành công${NC}"
argocd version --client

echo -e "${GREEN}Login using argocd CLI${NC}"
argocd login argocd.k8s.huydo.net --username admin
