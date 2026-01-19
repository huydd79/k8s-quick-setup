#!/bin/bash
# -----------------------------------------------------------------------------
# Script: 01.create.registry.secret.sh
# -----------------------------------------------------------------------------

if [ -f "./00.configure.sh" ]; then
    source ./00.configure.sh
else
    BLUE='\033[0;34m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    CYAN='\033[0;36m'
    MAGENTA='\033[0;35m'
    NC='\033[0m'
fi

REG_SERVER="harbor.cybr.huydo.net"
REG_EMAIL="admin@huydo.net"
SECRET_NAME="cybr-registry-key"
NAMESPACE="default"

echo -e "${BLUE}================================================================${NC}"
echo -e "${YELLOW}🚀 STARTING: CREATING IMAGE PULL SECRET FOR $REG_SERVER${NC}"
echo -e "${BLUE}================================================================${NC}"

# 1. Nhập Username
read -p "👤 Enter Registry Username: " REG_USER

# 2. Nhập Password hiển thị dấu *
echo -n "🔑 Enter Registry Password: "
REG_PASS=""
while IFS= read -r -s -n1 char; do
    [[ -z $char ]] && break          # Nhấn Enter để kết thúc
    if [[ $char == $'\177' ]]; then  # Xử lý phím Backspace
        if [ -n "$REG_PASS" ]; then
            REG_PASS=${REG_PASS%?}
            echo -ne '\b \b'
        fi
    else
        REG_PASS+=$char
        echo -n "*"
    fi
done
echo "" # Xuống dòng sau khi nhập xong

if [[ -z "$REG_USER" || -z "$REG_PASS" ]]; then
    echo -e "${RED}❌ Error: Username and Password cannot be empty!${NC}"
    exit 1
fi

# 3. Xử lý K8s Secret
if kubectl get secret $SECRET_NAME -n $NAMESPACE >/dev/null 2>&1; then
    echo -e "${CYAN}🔄 Refreshing existing secret...${NC}"
    kubectl delete secret $SECRET_NAME -n $NAMESPACE >/dev/null
fi

kubectl create secret docker-registry $SECRET_NAME \
  --docker-server=$REG_SERVER \
  --docker-username=$REG_USER \
  --docker-password=$REG_PASS \
  --docker-email=$REG_EMAIL \
  -n $NAMESPACE

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Success: Secret for created successfully!${NC}"
    echo -e "${GREEN}You can run below command to test registry auth:${NC}"
    echo -e "${YELLOW}crictl pull --creds \"${REG_USER}:<YOUR_PASSWORD>\" registry.cybr.huydo.net/hdo-busybox:latest${NC}"
else
    echo -e "${RED}❌ Error: Failed to create secret.${NC}"
    exit 1
fi
