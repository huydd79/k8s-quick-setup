#!/bin/bash
# -----------------------------------------------------------------------------
# Script: 02.deploy.hdo.busybox.sh
# Purpose: Deploy hdo-busybox tool using updated labels
# -----------------------------------------------------------------------------

source ./00.configure.sh

YAML_FILE="hdo-busybox.yaml"
DEPLOY_NAME="hdo-busybox"  # Đã đổi theo file YAML mới của bạn
SECRET_NAME="cybr-registry-key"
NAMESPACE="default"

echo -e "${BLUE}================================================================${NC}"
echo -e "${YELLOW}🚀 STARTING DEPLOYMENT: $DEPLOY_NAME (Build #5)${NC}"
echo -e "${BLUE}================================================================${NC}"

# 1. Check YAML existence
if [ ! -f "$YAML_FILE" ]; then
    echo -e "${RED}❌ Error: File '$YAML_FILE' not found!${NC}"
    exit 1
fi

# 2. Apply Deployment
echo -e "${CYAN}Applying manifest $YAML_FILE...${NC}"
kubectl apply -f $YAML_FILE

# 3. Wait for Pod Readiness
echo -e "${CYAN}Waiting for Pod to be ready...${NC}"
kubectl rollout status deployment/$DEPLOY_NAME -n $NAMESPACE

# 4. Get Pod Name using updated label 'app: hdo-busybox'
POD_NAME=$(kubectl get pods -l app=hdo-busybox -n $NAMESPACE -o jsonpath='{.items[0].metadata.name}')

echo -e "${BLUE}================================================================${NC}"
echo -e "${GREEN}✅ SUCCESS: $DEPLOY_NAME IS RUNNING!${NC}"
echo -e "${YELLOW}To enter the pod, run:${NC}"
echo -e "${MAGENTA}kubectl exec -it $POD_NAME -- bash${NC}"
echo -e "${BLUE}================================================================${NC}"