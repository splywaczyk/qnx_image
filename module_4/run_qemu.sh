#!/bin/bash
# module_4/run_qemu.sh
# QEMU launcher for QNX Security Policies module

set -e

# Colors
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get the module root directory
MODULE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default image
IMAGE="${1:-$MODULE_ROOT/images/qnx_secure_ipc.ifs}"

# Check if image exists
if [ ! -f "$IMAGE" ]; then
    echo -e "${RED}Error: Image not found: $IMAGE${NC}"
    echo ""
    echo "Usage: $0 [image_path]"
    echo "  Default: $MODULE_ROOT/images/qnx_secure_ipc.ifs"
    echo ""
    echo "Build the image first:"
    echo "  ./build_image.sh"
    exit 1
fi

echo -e "${BLUE}==========================================="
echo "  Module 4: Security Policies Demo"
echo "==========================================="
echo -e "${NC}"
echo "Image: $(basename "$IMAGE")"
echo "Size:  $(du -h "$IMAGE" | cut -f1)"
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
    -kernel "$IMAGE" \
    -m 512M \
    -smp 2 \
    -serial stdio \
    -display none \
    -no-reboot

echo ""
echo -e "${BLUE}QEMU session ended.${NC}"
