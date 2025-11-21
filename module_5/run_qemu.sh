#!/bin/bash
# module_5/run_qemu.sh - Run QNX Secure Boot Image

set -e

# Default to signed image, allow parameter override
IFS_IMAGE=$1

if [ ! -f "$IFS_IMAGE" ]; then
    echo "Error: Image not found: $IFS_IMAGE"
    echo ""
    echo "Build the image first:"
    echo "  ./module_5/build_and_sign.sh    # Build, sign, and verify"
    echo "  ./module_5/build_image.sh       # Build unsigned only"
    echo ""
    echo "Usage: $0 [image_path]"
    echo "  Default: module_5/images/qnx_signed.ifs"
    echo "  Example: $0 module_5/images/qnx_unsigned.ifs"
    exit 1
fi

echo "==========================================="
echo "  QNX Secure Boot - QEMU Launcher"
echo "==========================================="
echo "Image: $IFS_IMAGE"
echo "Size:  $(du -h "$IFS_IMAGE" | cut -f1)"
echo ""
echo "Press Ctrl+C QEMU"
echo "==========================================="
echo ""

qemu-system-x86_64 \
    -kernel "$IFS_IMAGE" \
    -cpu max \
    -m 2048 \
    -serial stdio \
    -display none \
    -no-reboot
