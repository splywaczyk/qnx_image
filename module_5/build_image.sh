#!/bin/bash
# module_5/build_image.sh - Build unsigned QNX secure boot image

set -e

# Get script directory and workspace root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source common QNX environment
source "$WORKSPACE_ROOT/scripts/qnx_common.sh"

qnx_print_header "Module 5: Secure Boot - Build Unsigned Image"
qnx_print_environment

echo "[1/2] Building verify_boot application..."
cd "$WORKSPACE_ROOT"
bazel build --platforms=//bazel/platforms:qnx_x86_64 //module_5/src:verify_boot

echo ""
echo "[2/2] Creating QNX image..."
mkdir -p "$WORKSPACE_ROOT/module_5/images"
mkifs -vvv "$WORKSPACE_ROOT/module_5/buildfiles/secure_boot.build" "$WORKSPACE_ROOT/module_5/images/qnx_unsigned.ifs"

echo ""
qnx_print_success "=========================================="
qnx_print_success "  Build Complete!"
qnx_print_success "=========================================="
echo "Image: module_5/images/qnx_unsigned.ifs"
echo "Size:  $(du -h "$WORKSPACE_ROOT/module_5/images/qnx_unsigned.ifs" | cut -f1)"
echo ""
echo "Next steps:"
echo "  1. Generate keys:"
echo "     cd $WORKSPACE_ROOT/module_5 && ./tools/generate_keys.sh"
echo "  2. Sign the image:"
echo "     cd $WORKSPACE_ROOT/module_5 && ./tools/sign_image.sh"
echo "  3. Verify signature:"
echo "     cd $WORKSPACE_ROOT/module_5 && ./tools/verify_image.sh"
echo "  4. Run signed image:"
echo "     cd $WORKSPACE_ROOT/module_5 && ./run_qemu.sh"
echo ""
echo "Or use the complete build script:"
echo "  cd $WORKSPACE_ROOT/module_5 && ./build_and_sign.sh"
echo "==========================================="
