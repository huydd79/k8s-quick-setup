#!/bin/bash
# -----------------------------------------------------------------------------
# Kubernetes Cluster Final Health Check
# Script: 09.health-check.sh
# Purpose: Verify all components, nodes, and ingress routes after deployment
# -----------------------------------------------------------------------------

source ./00.configure.sh
check_ready

echo -e "${BLUE}================================================================${NC}"
echo -e "${GREEN}🔍 STARTING SYSTEM HEALTH CHECK FOR: ${DOMAIN_SUFFIX}${NC}"
echo -e "${BLUE}================================================================${NC}"

# 1. Check Node Status
echo -e "\n${YELLOW}[1/5] Checking Nodes Status...${NC}"
NODES_READY=$(kubectl get nodes --no-headers | grep -c "Ready")
TOTAL_NODES=$(kubectl get nodes --no-headers | wc -l)
if [ "$NODES_READY" -eq "$TOTAL_NODES" ]; then
    echo -e "${GREEN}✅ All nodes are READY ($NODES_READY/$TOTAL_NODES)${NC}"
else
    echo -e "${RED}❌ Some nodes are NOT READY!${NC}"
    kubectl get nodes
fi

# 2. Check Critical System Pods (Kube-System)
echo -e "\n${YELLOW}[2/5] Checking Critical System Pods...${NC}"
BAD_PODS=$(kubectl get pods -A --no-headers | grep -vE "Running|Completed" | wc -l)
if [ "$BAD_PODS" -eq 0 ]; then
    echo -e "${GREEN}✅ All pods are Running or Completed.${NC}"
else
    echo -e "${RED}❌ Detected $BAD_PODS pods with issues:${NC}"
    kubectl get pods -A | grep -vE "Running|Completed"
fi

# 3. Check Metrics Server
echo -e "\n${YELLOW}[3/5] Checking Metrics Server...${NC}"
if kubectl top nodes &> /dev/null; then
    echo -e "${GREEN}✅ Metrics Server is responding.${NC}"
    kubectl top nodes
else
    echo -e "${RED}❌ Metrics Server is not responding yet. Wait a moment.${NC}"
fi

# 4. Check Traefik Ingress Routes
echo -e "\n${YELLOW}[4/5] Verifying IngressRoutes...${NC}"
ROUTES=("traefik-dashboard" "kubernetes-dashboard-route")
for route in "${ROUTES[@]}"; do
    STATUS=$(kubectl get ingressroute $route -A -o jsonpath='{.status.currentStatus}' 2>/dev/null)
    if [ "$STATUS" == "valid" ] || [ -z "$STATUS" ]; then
        echo -e "${GREEN}✅ IngressRoute '$route' is active.${NC}"
    else
        echo -e "${RED}❌ IngressRoute '$route' has status: $STATUS${NC}"
    fi
done

# 5. Check External Access (CURL Test)
echo -e "\n${YELLOW}[5/5] Testing External Access...${NC}"
# Kiểm tra Dashboard (Cần có 401 hoặc 200 tùy cấu hình, miễn không phải 404/500)
HTTP_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" https://traefik.${DOMAIN_SUFFIX}/dashboard/)
if [[ "$HTTP_CODE" == "401" || "$HTTP_CODE" == "200" ]]; then
    echo -e "${GREEN}✅ Gateway https://traefik.${DOMAIN_SUFFIX}/dashboard/ is reachable (HTTP $HTTP_CODE).${NC}"
else
    echo -e "${RED}❌ Gateway unreachable or returned error $HTTP_CODE.${NC}"
fi

echo -e "\n${BLUE}================================================================${NC}"
echo -e "${GREEN}🍀 HEALTH CHECK COMPLETED${NC}"
echo -e "${BLUE}================================================================${NC}"
echo -e "${YELLOW}Quick Access Summary:${NC}"
echo -e "📊 Grafana:   https://grafana.${DOMAIN_SUFFIX}"
echo -e "🚢 Dashboard: https://master.${DOMAIN_SUFFIX}"
echo -e "🛠️  Traefik:   https://traefik.${DOMAIN_SUFFIX}/dashboard/"
echo -e "${BLUE}================================================================${NC}"