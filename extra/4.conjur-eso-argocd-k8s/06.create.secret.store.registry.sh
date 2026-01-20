#!/bin/bash
# -----------------------------------------------------------------------------
# 06.create.secret.store.registry.sh - Setup Conjur SecretStore in App Namespace
# Author: Huy Do (huy.do@cyberark.com)
# -----------------------------------------------------------------------------
source ./00.config.sh
check_ready

echo -e "${BLUE}Step 1: Extracting Conjur SSL Certificate...${NC}"
# Extract cert from Conjur URL defined in 00.config.sh
CONJUR_CERT=$(openssl s_client -showcerts -connect conjur.cybr.huydo.net:443 </dev/null 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')

if [ -z "$CONJUR_CERT" ]; then
    echo -e "${RED}Error: Failed to fetch SSL certificate from $CONJUR_URL${NC}"
    exit 1
fi

echo -e "${BLUE}Step 2: Creating ConfigMap 'conjur-cm' in $APP_NAMESPACE...${NC}"
# Ensure the namespace exists before applying
kubectl create namespace "$APP_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "$APP_NAMESPACE" create configmap conjur-cm \
    --from-literal "CONJUR_SSL_CERTIFICATE=${CONJUR_CERT}" \
    --dry-run=client -o yaml | kubectl apply -f -

echo -e "${BLUE}Step 3: Preparing and Applying SecretStore manifest...${NC}"
YML_TEMP="/tmp/conjur-registry-store.yaml"

# Replace placeholders in the base SecretStore template
sed "s|{CONJUR_URL}|$CONJUR_URL|g" ./yaml/conjur-secret-store-jwt.yaml | \
sed "s|{CONJUR_ACCOUNT}|$CONJUR_ACCOUNT|g" > "$YML_TEMP"

# Apply specifically to the application namespace
kubectl apply -n "$APP_NAMESPACE" -f "$YML_TEMP"

echo -e "${GREEN}Step 4: Verification in $APP_NAMESPACE...${NC}"
rm -f "$YML_TEMP"
kubectl -n "$APP_NAMESPACE" get secretstore conjur