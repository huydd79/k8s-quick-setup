#!/bin/bash
# -----------------------------------------------------------------------------
# Script: u1.delete.jenkins.svc.sh
# Purpose: Cleanup Jenkins Service Account resources
# -----------------------------------------------------------------------------

BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}================================================================${NC}"
echo -e "${RED}🗑️  DELETING JENKINS SERVICE ACCOUNT RESOURCES${NC}"
echo -e "${BLUE}================================================================${NC}"

# Xóa ClusterRoleBinding
kubectl delete clusterrolebinding jenkins-admin-binding --ignore-not-found

# Xóa ServiceAccount
kubectl delete serviceaccount jenkins-admin -n default --ignore-not-found

# Xóa Secret chứa token
kubectl delete secret jenkins-admin-token -n default --ignore-not-found

echo -e "${GREEN}✅ SUCCESS: Jenkins Service Account resources removed.${NC}"
echo -e "${BLUE}================================================================${NC}"