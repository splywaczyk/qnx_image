#!/bin/bash
# module_2/run_qemu.sh - Run Module 2 QNX Extended Image

set -e

IFS_IMAGE=$1

if [ ! -f "$IFS_IMAGE" ]; then
    echo "Error: Image not found: $IFS_IMAGE"
    echo "Run ./build_image.sh first"
    exit 1
fi

echo "Starting QNX Module 2: Extended System..."
echo "Press Ctrl+C"
echo ""

qemu-system-x86_64 \
    -kernel "$IFS_IMAGE" \
    -cpu max \
    -m 512M \
    -smp 2 \
    -serial mon:stdio \
    -display none \
    -no-reboot \
    -nographic
