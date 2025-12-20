#!/bin/bash
source ./00.configure.sh
check_ready

TOKEN=$(kubectl -n kubernetes-dashboard get secret dashboard-admin-secret -o jsonpath="{.data.token}" | base64 -d)

echo -e "${BLUE}--- 🔑 Kubernetes Dashboard Token ---${NC}"
echo -e "${GREEN}${TOKEN}${NC}"