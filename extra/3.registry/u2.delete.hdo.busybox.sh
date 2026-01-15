#!/bin/bash
# -----------------------------------------------------------------------------
# Script: u2.delete.hdo.busybox.sh
# Purpose: Clean up hdo-busybox deployment using YAML
# -----------------------------------------------------------------------------

source ./00.configure.sh

YAML_FILE="hdo-busybox.yaml"
DEPLOY_NAME="hdo-busybox"

echo -e "${BLUE}================================================================${NC}"
echo -e "${RED}🗑️  DELETING DEPLOYMENT: $DEPLOY_NAME${NC}"
echo -e "${BLUE}================================================================${NC}"

if [ -f "$YAML_FILE" ]; then
    kubectl delete -f $YAML_FILE --ignore-not-found
    echo -e "${GREEN}✅ Success: Resources removed.${NC}"
else
    echo -e "${YELLOW}⚠️  Notice: $YAML_FILE not found. Trying by name...${NC}"
    kubectl delete deployment $DEPLOY_NAME --ignore-not-found
fi

echo -e "${BLUE}================================================================${NC}"