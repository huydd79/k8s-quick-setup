#!/bin/bash
source ./00.config.sh
check_ready

echo -e "${RED}Warning: This will delete ESO resources and the Operator.${NC}"
read -p "Are you sure? (y/n) " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 1

echo -e "${BLUE}Step 1: Deleting ArgoCD-specific ESO resources...${NC}"
kubectl delete externalsecret gitlab-repo-conjur-sync -n "$ARGOCD_NAMESPACE" --ignore-not-found
kubectl delete secretstore conjur -n "$ARGOCD_NAMESPACE" --ignore-not-found
kubectl delete secret gitlab-repo-creds-conjur -n "$ARGOCD_NAMESPACE" --ignore-not-found

echo -e "${BLUE}Step 2: Uninstalling ESO Operator (Helm)...${NC}"
helm uninstall external-secrets -n "$ESO_NAMESPACE" --ignore-not-found
kubectl delete namespace "$ESO_NAMESPACE" --ignore-not-found

echo -e "${GREEN}Cleanup complete.${NC}"