#!/bin/bash
# -----------------------------------------------------------------------------
# 01.install-eso.sh - Force Install/Upgrade ESO with CRDs
# -----------------------------------------------------------------------------
source ./00.config.sh
check_ready

echo -e "${BLUE}Step 1: Ensuring Helm is ready...${NC}"
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

echo -e "${BLUE}Step 2: Deploying/Upgrading External Secrets Operator...${NC}"
# Sử dụng upgrade --install và ép installCRDs=true
helm upgrade --install external-secrets external-secrets/external-secrets \
    -n "$ESO_NAMESPACE" \
    --create-namespace \
    --set installCRDs=true \
    --wait

echo -e "${GREEN}ESO has been deployed/upgraded with CRDs.${NC}"

echo -e "${BLUE}Step 3: Verifying CRDs presence...${NC}"
kubectl get crd | grep external-secrets