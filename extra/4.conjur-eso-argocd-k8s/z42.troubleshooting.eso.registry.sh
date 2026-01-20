#!/bin/bash
source ./00.config.sh
check_ready

echo -e "${BLUE}Step 1: Checking ExternalSecret status in $APP_NAMESPACE...${NC}"
kubectl -n "$APP_NAMESPACE" describe externalsecret gitlab-repo-conjur-sync | grep -A 10 "Events:"

echo -e "${BLUE}Step 2: Checking ESO Controller logs...${NC}"
kubectl -n "$ESO_NAMESPACE" logs -l app.kubernetes.io/name=external-secrets --tail=50

echo -e "${BLUE}Step 3: Checking SecretStore status in $APP_NAMESPACE...${NC}"
kubectl -n "$APP_NAMESPACE" get secretstore conjur -o wide