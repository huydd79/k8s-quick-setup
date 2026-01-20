#!/bin/bash
# -----------------------------------------------------------------------------
# Huy Do huy.do@cyberark.com
# 01.install.argocd.sh
# -----------------------------------------------------------------------------
source ./00.config.sh
check_ready

echo -e "${BLUE}Step 1: Creating Namespace...${NC}"
kubectl create namespace $ARGOCD_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo -e "${BLUE}Step 2: Installing ArgoCD ($ARGOCD_VERSION)...${NC}"
kubectl apply -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/$ARGOCD_VERSION/manifests/install.yaml

echo -e "${BLUE}Step 3: Configuring Insecure Mode via ConfigMap (Official Method)...${NC}"
# Sử dụng ConfigMap để bật insecure thay vì patch command
kubectl patch cm argocd-cmd-params-cm -n $ARGOCD_NAMESPACE --type merge -p '{"data": {"server.insecure": "true"}}'

echo -e "${YELLOW}Waiting for ArgoCD components to be ready...${NC}"
kubectl rollout status deployment argocd-server -n $ARGOCD_NAMESPACE --timeout=300s

# Lấy mật khẩu admin
ARGOCD_PWD=$(kubectl -n $ARGOCD_NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo -e "${GREEN}ArgoCD installed successfully!${NC}"
echo -e "${YELLOW}Initial Admin Password: ${GREEN}$ARGOCD_PWD${NC}"