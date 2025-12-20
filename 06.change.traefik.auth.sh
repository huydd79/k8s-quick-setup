#!/bin/bash
# -----------------------------------------------------------------------------
# Change Traefik Dashboard Credentials
# Script: 06.change.traefik-auth.sh
# -----------------------------------------------------------------------------

# Load configuration and check readiness
source ./00.configure.sh
check_ready

NAMESPACE="traefik-v2"
SECRET_NAME="traefik-dashboard-auth"

echo -e "${GREEN}--- 🔐 Traefik Password Updater ---${NC}"

# --- Part 0: Check and Install httpd-tools (for htpasswd) ---
if ! command -v htpasswd &> /dev/null; then
    echo -e "${YELLOW}>> 'htpasswd' not found. Installing httpd-tools...${NC}"
    sudo dnf install -y httpd-tools
    if [ $? -ne 0 ]; then
        echo -e "${RED}ERROR: Failed to install httpd-tools. Please install it manually: sudo dnf install httpd-tools${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ httpd-tools installed successfully.${NC}"
fi

# 1. Get new credentials from user
echo -e "${YELLOW}>>> Enter your new login information <<<${NC}"
read -p "New Username: " NEW_USER
if [ -z "$NEW_USER" ]; then
    echo -e "${RED}Error: Username cannot be empty!${NC}"
    exit 1
fi

read -sp "New Password: " NEW_PASS
echo -e "\n"
read -sp "Confirm New Password: " CONFIRM_PASS
echo -e "\n"

if [ "$NEW_PASS" != "$CONFIRM_PASS" ]; then
    echo -e "${RED}Error: Passwords do not match!${NC}"
    exit 1
fi

# 2. Generate new hash
# RAW_HASH will be in "user:hash" format
RAW_HASH=$(htpasswd -nb "$NEW_USER" "$NEW_PASS")

echo -e "${BLUE}## Updating credentials in Kubernetes...${NC}"

# 3. Create Secret - Use single quotes to escape $ symbols in hash
# We delete first to ensure it's a clean overwrite
kubectl delete secret $SECRET_NAME -n $NAMESPACE --ignore-not-found
kubectl create secret generic $SECRET_NAME \
  --namespace=$NAMESPACE \
  --from-literal=users="${RAW_HASH}"

# 4. Restart Traefik to apply changes immediately
echo -e "${BLUE}## Restarting Traefik pods...${NC}"
kubectl rollout restart deployment traefik -n $NAMESPACE

# 5. Final result
if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}--- ✅ Credentials Updated Successfully! ---${NC}"
    echo -e "User: $NEW_USER"
    echo -e "\n${BLUE}Verification command (Wait 10s):${NC}"
    echo -e "curl -k -u '$NEW_USER:[YOUR_PASS]' https://traefik.${DOMAIN_SUFFIX}/dashboard/"
else
    echo -e "\n${RED}--- ❌ Failed to update credentials ---${NC}"
fi

echo -e "\nPress ENTER to finish."
read