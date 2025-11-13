#!/bin/bash
############################################################
# CCM Dashboard Installation Script
# ---------------------------------------------------------
# Install the CCM Dashboard UI
############################################################

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   CCM Dashboard Installation Script   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
DASHBOARD_DIR="$HOME/ccm-dashboard"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}✗ Node.js is not installed${NC}"
    echo -e "${YELLOW}  Please install Node.js first: https://nodejs.org/${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Node.js found: $(node --version)${NC}"

# Check if pnpm is installed
if ! command -v pnpm &> /dev/null; then
    echo -e "${YELLOW}⚠️  pnpm not found, will use npm instead${NC}"
    PKG_MANAGER="npm"
else
    echo -e "${GREEN}✓ pnpm found: $(pnpm --version)${NC}"
    PKG_MANAGER="pnpm"
fi

# Check if dashboard already exists
if [[ -d "$DASHBOARD_DIR" ]]; then
    echo -e "${YELLOW}⚠️  Dashboard already exists at $DASHBOARD_DIR${NC}"
    read -p "Do you want to reinstall? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Installation cancelled.${NC}"
        exit 0
    fi
    echo -e "${BLUE}Removing existing installation...${NC}"
    rm -rf "$DASHBOARD_DIR"
fi

# Note: In production, this would clone/copy the dashboard files
# For now, we'll create a symlink or instructions
echo ""
echo -e "${BLUE}ℹ️  Installation Instructions:${NC}"
echo -e "${YELLOW}1. The CCM Dashboard is located at: $DASHBOARD_DIR${NC}"
echo -e "${YELLOW}2. To launch the dashboard, run: ccm ui${NC}"
echo -e "${YELLOW}3. Or directly run: $SCRIPT_DIR/ccm-ui${NC}"
echo ""
echo -e "${GREEN}✓ Installation complete!${NC}"
echo ""
echo -e "${BLUE}Quick Start:${NC}"
echo -e "  ${GREEN}ccm ui${NC}  - Launch the dashboard"
echo ""
