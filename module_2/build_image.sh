#!/bin/bash
# module_2/build_image.sh - Build Module 2: Extended System

set -e

# Get script directory and workspace root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source common QNX environment
source "$WORKSPACE_ROOT/scripts/qnx_common.sh"

qnx_print_header "Module 2: Building Extended System"
qnx_print_environment

# Build the application from module_1
echo "[1/2] Building application..."
cd "$WORKSPACE_ROOT"
bazel build //module_1/src:hello_world --platforms=//bazel/platforms:qnx_x86_64

# Create images directory
mkdir -p "$WORKSPACE_ROOT/module_2/images"

# Build the IFS image
echo ""
echo "[2/2] Creating QNX image..."
mkifs -vvv "$WORKSPACE_ROOT/module_2/buildfiles/extended.build" "$WORKSPACE_ROOT/module_2/images/qnx_extended.ifs"

echo ""
qnx_print_success "=========================================="
qnx_print_success "  Build Complete!"
qnx_print_success "=========================================="
echo "Image: module_2/images/qnx_extended.ifs"
echo "Size:  $(du -h "$WORKSPACE_ROOT/module_2/images/qnx_extended.ifs" | cut -f1)"
echo ""
echo "To run:"
echo "  cd $WORKSPACE_ROOT/module_2"
echo "  ./run_qemu.sh"
echo "=========================================="
