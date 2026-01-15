#!/bin/bash
# -----------------------------------------------------------------------------
# Script: 01.create.jenkins.svc.sh
# Purpose: Create Service Account, ClusterRoleBinding and Token for Jenkins
# -----------------------------------------------------------------------------

# Load màu sắc và cấu hình nếu có (từ file 00 của bạn)
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}================================================================${NC}"
echo -e "${YELLOW}⚙️  CREATING K8S SERVICE ACCOUNT FOR JENKINS${NC}"
echo -e "${BLUE}================================================================${NC}"

# 1. Tạo Service Account
echo -e "${CYAN}Step 1: Creating ServiceAccount 'jenkins-admin'...${NC}"
kubectl create serviceaccount jenkins-admin -n default --dry-run=client -o yaml | kubectl apply -f -

# 2. Tạo ClusterRoleBinding (Gán quyền Admin)
echo -e "${CYAN}Step 2: Assigning Cluster-Admin role...${NC}"
kubectl create clusterrolebinding jenkins-admin-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=default:jenkins-admin \
  --dry-run=client -o yaml | kubectl apply -f -

# 3. Tạo Secret để lấy Token (Dành cho K8s 1.24+)
echo -e "${CYAN}Step 3: Creating Long-lived Token Secret...${NC}"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: jenkins-admin-token
  namespace: default
  annotations:
    kubernetes.io/service-account.name: jenkins-admin
type: kubernetes.io/service-account-token
EOF

echo -e "${BLUE}----------------------------------------------------------------${NC}"
echo -e "${GREEN}✅ SUCCESS: Service Account and Token created!${NC}"
echo -e "${YELLOW}👇 COPY THE TOKEN BELOW TO JENKINS (Secret Text):${NC}"
echo -e "${BLUE}----------------------------------------------------------------${NC}"

# 4. Trích xuất Token và in ra màn hình
TOKEN=$(kubectl get secret jenkins-admin-token -n default -o jsonpath={.data.token} | base64 -d)
echo -e "${WHITE}$TOKEN${NC}"
echo -e "${GREEN}Up date above value to Jenkins's credential: k8s-token-creds${NC}"
echo -e "${BLUE}----------------------------------------------------------------${NC}"