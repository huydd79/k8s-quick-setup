#!/bin/bash
# -----------------------------------------------------------------------------
# Script: u1.clear.registry.secret.sh
# Purpose: Delete Image Pull Secret for harbor.cybr.huydo.net
# -----------------------------------------------------------------------------

# Nạp các biến màu và cấu hình chung
source ./00.configure.sh

SECRET_NAME="cybr-registry-key"
NAMESPACE="default"

echo -e "${BLUE}================================================================${NC}"
echo -e "${RED}🗑️  CLEANING: DELETING IMAGE PULL SECRET${NC}"
echo -e "${BLUE}================================================================${NC}"

# Kiểm tra sự tồn tại của secret trước khi xóa để đưa ra thông báo phù hợp
if kubectl get secret $SECRET_NAME -n $NAMESPACE >/dev/null 2>&1; then
    echo -e "${CYAN}Removing secret '${SECRET_NAME}' từ namespace '${NAMESPACE}'...${NC}"
    
    kubectl delete secret $SECRET_NAME -n $NAMESPACE
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Success: Secret đã được xóa thành công.${NC}"
    else
        echo -e "${RED}❌ Error: Không thể xóa secret. Vui lòng kiểm tra lại quyền truy cập.${NC}"
    fi
else
    echo -e "${YELLOW}ℹ️  Notice: Secret '${SECRET_NAME}' không tồn tại. Không có gì để xóa.${NC}"
fi

echo -e "${BLUE}================================================================${NC}"
echo -e "${GREEN}🍀 CLEANUP COMPLETED${NC}"
echo -e "${BLUE}================================================================${NC}"