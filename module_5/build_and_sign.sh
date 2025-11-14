#!/bin/bash
# module_5/build_and_sign.sh - Build and sign secure boot image

set -e

# Get script directory and workspace root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source common QNX environment
source "$WORKSPACE_ROOT/scripts/qnx_common.sh"

echo "==========================================="
echo "  QNX Secure Boot Build Process"
echo "==========================================="
echo ""

# Check for keys
if [ ! -f "module_5/keys/qnx_private.pem" ]; then
    echo "Error: Keys not found. Generating keys..."
    echo ""
    ./module_5/tools/generate_keys.sh
    echo ""
fi

# Step 1: Build application
echo "[1/4] Building verify_boot application..."
bazel build --config=qnx //module_5/src:verify_boot

# Step 2: Create unsigned image
echo ""
echo "[2/4] Creating unsigned image..."
mkdir -p module_5/images
mkifs -vvv module_5/buildfiles/secure_boot.build module_5/images/qnx_unsigned.ifs

# Step 3: Sign image
echo ""
echo "[3/4] Signing image..."
./module_5/tools/sign_image.sh module_5/images/qnx_unsigned.ifs module_5/images/qnx_signed.ifs

# Step 4: Verify signature
echo ""
echo "[4/4] Verifying signed image..."
./module_5/tools/verify_image.sh module_5/images/qnx_signed.ifs

echo ""
echo "==========================================="
echo "Secure Boot Image Ready!"
echo "==========================================="
echo "Unsigned: module_5/images/qnx_unsigned.ifs"
echo "Signed:   module_5/images/qnx_signed.ifs"
echo ""
echo "To test:"
echo "  ./module_5/run_qemu.sh"
echo "==========================================="
