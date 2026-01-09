#!/bin/bash
# 03_ipc/run_qemu.sh
# QEMU launcher for QNX Security Policies module

set -e

# Colors
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

IFS_IMAGE=$1

# Check if image exists
if [ ! -f "$IFS_IMAGE" ]; then
    echo -e "${RED}Error: Image not found: $IFS_IMAGE${NC}"
    echo ""
    echo "Usage: $0 <image_path>"
    exit 1
fi

echo -e "${BLUE}==========================================="
echo "  Module 4: Security Policies Demo"
echo "==========================================="
echo -e "${NC}"
echo "Image: $(basename "$IFS_IMAGE")"
echo "Size:  $(du -h "$IFS_IMAGE" | cut -f1)"
echo ""
echo -e "${YELLOW}Security Features:${NC}"
echo "  • procnto -S (security enforcement)"
echo "  • IPC access control policy"
echo "  • sender1: AUTHORIZED"
echo "  • sender2: DENIED"
echo ""
echo -e "${YELLOW}Controls:${NC}"
echo "  • Ctrl+A then X: Exit QEMU"
echo "  • Ctrl+A then C: QEMU console"
echo ""
echo -e "${BLUE}Starting QEMU...${NC}"
echo ""

# Run QEMU
qemu-system-x86_64 \
    -kernel "$IFS_IMAGE" \
    -cpu max \
    -m 2048 \
    -serial stdio \
    -display none \
    -no-reboot

echo ""
echo -e "${BLUE}QEMU session ended.${NC}"
