#!/bin/bash
# -----------------------------------------------------------------------------
# Global Configuration - Edit this file first!
# -----------------------------------------------------------------------------

# Set to true once you have verified the settings below
READY=false

# --- Infrastructure & Domain ---
DOMAIN_SUFFIX="change.to.your.domain"    #<< Change to your domain
POD_CIDR="10.224.0.0/16"                 #<< Change to your LAB CIDR

# --- ANSI Colors ---
GREEN='\033[32m'
BLUE='\033[34m'
YELLOW='\033[33m'
RED='\033[31m'
NC='\033[0m'

# --- Safety Check Function ---
check_ready() {
    if [ "$READY" != "true" ]; then
        echo -e "${RED}Error: Setup is not ready!${NC}"
        echo -e "${YELLOW}Please edit '00.configure.sh' and set READY=true.${NC}"
        exit 1
    fi
}
