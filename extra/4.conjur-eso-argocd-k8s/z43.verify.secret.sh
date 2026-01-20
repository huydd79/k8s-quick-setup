#!/bin/bash
source ./00.config.sh
check_ready

echo -e "${BLUE}Inspecting the synced Kubernetes Secret: gitlab-repo-creds-conjur...${NC}"
kubectl -n "$ARGOCD_NAMESPACE" get secret gitlab-repo-creds-conjur --show-labels

echo -e "${BLUE}Verifying Data Fields (Decoded):${NC}"
USER_VAL=$(kubectl -n "$ARGOCD_NAMESPACE" get secret gitlab-repo-creds-conjur -o jsonpath="{.data.username}" | base64 --decode)
PASS_VAL=$(kubectl -n "$ARGOCD_NAMESPACE" get secret gitlab-repo-creds-conjur -o jsonpath="{.data.password}" | base64 --decode)

echo -e "Username: $USER_VAL"
echo -e "Password: ${PASS_VAL:0:4}******"

if [ ! -z "$PASS_VAL" ]; then
    echo -e "${GREEN}SUCCESS: Secret is correctly populated from Conjur.${NC}"
else
    echo -e "${RED}ERROR: Secret data is empty.${NC}"
fi