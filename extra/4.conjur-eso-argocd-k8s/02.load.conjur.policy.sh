#!/bin/bash
# -----------------------------------------------------------------------------
# 02.load-conjur-policy.sh - Load Conjur Policies for Kubernetes Authentication
# Author: Huy Do (huy.do@cyberark.com)
# Date: 2026-01-17
# -----------------------------------------------------------------------------
source ./00.config.sh
check_ready

echo -e "${BLUE}Loading Conjur Policies for JWT authentication...${NC}"

# Load the policy file into Conjur root branch to define K8s Authenticator and Hosts
# The variables paths are expected to be created/synced by CyberArk Vault Synchronizer
if conjur policy load -f ./yaml/conjur-eso-jwt-policy.yaml -b root; then
    echo -e "${GREEN}Policy loaded successfully.${NC}"
else
    echo -e "${RED}Error: Failed to load policy. Please check Conjur CLI session.${NC}"
    exit 1
fi

echo -e "${GREEN}Conjur infrastructure is ready for secret synchronization.${NC}"