#!/bin/bash
# -------------------------------------------------------------------------------
# Script: 07.config.app.sh
# Description: Deploy webapp03 using ArgoCD Application via GitOps
# Author: Huy Do (huydd79)
# -------------------------------------------------------------------------------

# Load global configurations
source ./00.config.sh

check_ready

# Application variables
APP_NAME="webapp03"
REPO_PATH="apps/webapp03"
DEST_NAMESPACE="default"

echo -e "${BLUE}Cleaning up existing Application if any...${NC}"
kubectl delete app $APP_NAME -n $ARGOCD_NAMESPACE --ignore-not-found

echo -e "${BLUE}Creating new ArgoCD Application: ${YELLOW}$APP_NAME${NC}..."

# Apply ArgoCD Application Manifest
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: $APP_NAME
  namespace: $ARGOCD_NAMESPACE
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: '$GITLAB_REPO_URL'
    targetRevision: HEAD
    path: $REPO_PATH
  destination:
    server: https://kubernetes.default.svc
    namespace: $DEST_NAMESPACE
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
    - ApplyOutOfSyncOnly=true
EOF

echo -e "${GREEN}Deployment command sent successfully!${NC}"
echo -e "${GREEN}Please check the ArgoCD Dashboard to monitor the sync status.${NC}"