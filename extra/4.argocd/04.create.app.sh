#!/bin/bash
source ./00.config.sh

APP_NAME="webapp02" # Tên App mới
REPO_PATH="apps/webapp02" # Thư mục mới trên Git

echo -e "${BLUE}Dọn dẹp App cũ nếu có...${NC}"
kubectl delete app guestbook-demo -n $ARGOCD_NAMESPACE --ignore-not-found

echo -e "${BLUE}Tạo App mới $APP_NAME...${NC}"
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: $APP_NAME
  namespace: $ARGOCD_NAMESPACE
spec:
  project: default
  source:
    repoURL: '$GITLAB_REPO_URL'
    targetRevision: HEAD
    path: $REPO_PATH
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF