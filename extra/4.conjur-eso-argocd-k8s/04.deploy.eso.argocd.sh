#!/bin/bash
# -----------------------------------------------------------------------------
# 04.deploy-eso-argocd.sh - Create ArgoCD Repo Secret backed by Conjur
# -----------------------------------------------------------------------------
source ./00.config.sh
check_ready

echo -e "${BLUE}Step 1: Preparing full ArgoCD Repo manifest...${NC}"
YML_TEMP="/tmp/eso-argocd-full.yaml"
API_VERSION=$(kubectl api-resources | grep -w "externalsecrets" | awk '{print $3}')

# Replace all placeholders including ArgoCD specific parameters
sed "s|external-secrets.io/v1|$API_VERSION|g" ./yaml/conjur-external-secret.yaml | \
sed "s|{GITLAB_REPO_URL}|$GITLAB_REPO_URL|g" | \
sed "s|{APP_NAMESPACE}|$APP_NAMESPACE|g" | \
sed "s|{PATH_USER}|$PATH_USER|g" | \
sed "s|{PATH_TOKEN}|$PATH_TOKEN|g" > "$YML_TEMP"

echo -e "${BLUE}Step 2: Applying ExternalSecret to $ARGOCD_NAMESPACE...${NC}"
kubectl apply -f "$YML_TEMP" -n "$ARGOCD_NAMESPACE"

echo -e "${GREEN}Waiting for synchronization (10s)...${NC}"
sleep 10
kubectl get externalsecret gitlab-repo-conjur-sync -n "$ARGOCD_NAMESPACE"

rm -f "$YML_TEMP"