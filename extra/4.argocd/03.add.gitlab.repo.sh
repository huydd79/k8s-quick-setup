#!/bin/bash
# 03.add.gitlab.repo.sh - Cập nhật theo tài liệu ArgoCD Latest
source ./00.config.sh

echo -e "${BLUE}Nạp cấu hình Repo theo chuẩn ArgoCD v3.x/Latest...${NC}"

# Xóa để dọn dẹp cache xác thực cũ
kubectl delete secret gitlab-repo-creds -n $ARGOCD_NAMESPACE --ignore-not-found

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-repo-creds
  namespace: $ARGOCD_NAMESPACE
  labels:
    argocd.argoproj.io/secret-type: repository # Label bắt buộc để ArgoCD nhận diện
stringData:
  url: "$GITLAB_REPO_URL"
  username: "$GITLAB_USER"          # Username bạn vừa test ls-remote thành công
  password: "$GITLAB_TOKEN"    # Token glpat-sAcZu...
  project: "$APP_NAMESPACE"         
  
  # Ép dùng Basic Auth để tránh lỗi 401 như log bạn vừa gặp
  forceHttpBasicAuth: "true" 
  
  # Bỏ qua check TLS nếu đi qua Nginx Proxy
  insecure: "true"
  
  # Type là git (mặc định nếu không ghi, nhưng ghi vào cho chắc)
  type: git
EOF

echo -e "${GREEN}Đã cập nhật Repo với tham số forceHttpBasicAuth.${NC}"