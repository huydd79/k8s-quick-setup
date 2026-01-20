#!/bin/bash
# -----------------------------------------------------------------------------
# 07.deploy.eso.registry.sh - Create Registry Pull Secret backed by Conjur
# Author: Huy Do (huy.do@cyberark.com)
# -----------------------------------------------------------------------------
source ./00.config.sh
check_ready

echo -e "${BLUE}Step 1: Preparing Registry ExternalSecret manifest...${NC}"
YML_TEMP="/tmp/eso-registry-full.yaml"

# Determine the API version for ExternalSecrets
API_VERSION=$(kubectl api-resources | grep -w "externalsecrets" | awk '{print $3}')

# Replace all placeholders using 'sed'
# Using '|' as a delimiter to safely handle paths with slashes
sed "s|external-secrets.io/v1|$API_VERSION|g" ./yaml/conjur-registry-secret.yaml | \
sed "s|{APP_NAMESPACE}|$APP_NAMESPACE|g" | \
sed "s|{REGISTRY}|$REGISTRY|g" | \
sed "s|{REGISTRY_USER_PATH}|$REGISTRY_USER_PATH|g" | \
sed "s|{REGISTRY_PASS_PATH}|$REGISTRY_PASS_PATH|g" > "$YML_TEMP"

echo -e "${BLUE}Step 2: Applying ExternalSecret to $APP_NAMESPACE...${NC}"
kubectl apply -f "$YML_TEMP" -n "$APP_NAMESPACE"

echo -e "${GREEN}Waiting for synchronization (10s)...${NC}"
sleep 10

# Verify the ExternalSecret status
kubectl get externalsecret registry-conjur-sync -n "$APP_NAMESPACE"

# Cleanup temporary file
rm -f "$YML_TEMP"