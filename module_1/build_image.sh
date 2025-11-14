#!/bin/bash
# module_1/build_image.sh - Build Module 1: Hello World

set -e

# Get script directory and workspace root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source common QNX environment
source "$WORKSPACE_ROOT/scripts/qnx_common.sh"

qnx_print_header "Module 1: Building Hello World"
qnx_print_environment

# Build the application
echo "[1/2] Building application..."
cd "$WORKSPACE_ROOT"
bazel build //module_1/src:hello_world --platforms=//bazel/platforms:qnx_x86_64

# Create images directory
mkdir -p module_1/images

# Build the IFS image
echo ""
echo "[2/2] Creating QNX image..."
mkifs -vvv module_1/buildfiles/qnx_minimal.build module_1/images/qnx_minimal.ifs

echo ""
echo "=========================================="
echo "Image built successfully!"
echo "=========================================="
echo "Image: module_1/images/qnx_minimal.ifs"
echo "Size: $(du -h module_1/images/qnx_minimal.ifs | cut -f1)"
echo ""
echo "To run:"
echo "  ./module_1/run_qemu.sh"
echo "=========================================="
