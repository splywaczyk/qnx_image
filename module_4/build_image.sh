#!/bin/bash
# module_4/build_image.sh
# Build script for QNX Security Policies and Access Control module

set -e

# Get the module root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MODULE_ROOT="$SCRIPT_DIR"

# Source common QNX environment
source "$WORKSPACE_ROOT/scripts/qnx_common.sh"

qnx_print_header "Module 4: Security Policies Build"
qnx_print_environment

echo "[1/3] Building secure IPC applications..."

cd "$WORKSPACE_ROOT"
bazel build --platforms=//bazel/platforms:qnx_x86_64 \
    //module_4/src:receiver_secure \
    //module_4/src:sender1_secure \
    //module_4/src:sender2_secure

if [ $? -ne 0 ]; then
    echo "Error: Bazel build failed"
    exit 1
fi

echo ""
echo "[2/3] Verifying security policy..."
POLICY_FILE="$MODULE_ROOT/secpol/ipc_policy.sp"
if [ ! -f "$POLICY_FILE" ]; then
    echo "Error: Security policy not found: $POLICY_FILE"
    exit 1
fi

echo ""
echo "[3/3] Creating QNX image..."

# Create images directory
mkdir -p "$MODULE_ROOT/images"

# Set environment variables for mkifs
export MODULE_ROOT
export QNX_TARGET
export QNX_HOST

# Build the IFS image
mkifs -v "$MODULE_ROOT/buildfiles/ipc_secure.build" \
      "$MODULE_ROOT/images/qnx_secure_ipc.ifs"

if [ $? -ne 0 ]; then
    echo "Error: mkifs failed"
    exit 1
fi

echo ""
qnx_print_success "=========================================="
qnx_print_success "  Build Complete!"
qnx_print_success "=========================================="
echo "Image: module_4/images/qnx_secure_ipc.ifs"
echo "Size:  $(du -h "$MODULE_ROOT/images/qnx_secure_ipc.ifs" | cut -f1)"
echo ""
echo "To run:"
echo "  cd $WORKSPACE_ROOT/module_4"
echo "  ./run_qemu.sh"
echo "=========================================="
