#!/bin/bash
# -----------------------------------------------------------------------------
# 03.create-secret-store.sh - Configure Conjur SecretStore in ArgoCD namespace
# Author: Huy Do (huy.do@cyberark.com)
# -----------------------------------------------------------------------------
source ./00.config.sh
check_ready

echo -e "${BLUE}Step 1: Extracting Conjur SSL Certificate...${NC}"
CONJUR_CERT=$(openssl s_client -showcerts -connect conjur.cybr.huydo.net:443 </dev/null 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')

if [ -z "$CONJUR_CERT" ]; then
    echo -e "${RED}Error: Failed to fetch SSL certificate.${NC}"
    exit 1
fi

echo -e "${BLUE}Step 2: Creating ConfigMap in $ARGOCD_NAMESPACE...${NC}"
kubectl -n "$ARGOCD_NAMESPACE" create configmap conjur-cm \
    --from-literal "CONJUR_SSL_CERTIFICATE=${CONJUR_CERT}" \
    --dry-run=client -o yaml | kubectl apply -f -

echo -e "${BLUE}Step 3: Preparing SecretStore manifest...${NC}"
YML_TEMP="/tmp/conjur-jwt-store.yaml"
API_VERSION=$(kubectl api-resources | grep -w "secretstores" | awk '{print $3}')

# Apply transformations
sed "s|external-secrets.io/v1|$API_VERSION|g" ./yaml/conjur-secret-store-jwt.yaml | \
sed "s|{CONJUR_URL}|$CONJUR_URL|g" | \
sed "s|{CONJUR_ACCOUNT}|$CONJUR_ACCOUNT|g" > "$YML_TEMP"

echo -e "${BLUE}Step 4: Applying SA and SecretStore to $ARGOCD_NAMESPACE...${NC}"
kubectl apply -n "$ARGOCD_NAMESPACE" -f "$YML_TEMP"

rm -f "$YML_TEMP"
kubectl -n "$ARGOCD_NAMESPACE" get secretstore conjur