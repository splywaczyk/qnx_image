#!/bin/bash
# module_2/run_qemu.sh - Run Module 2 QNX Extended Image

set -e

IMAGE="./images/qnx_extended.ifs"

if [ ! -f "$IMAGE" ]; then
    echo "Error: Image not found: $IMAGE"
    echo "Run ./build_image.sh first"
    exit 1
fi

echo "Starting QNX Module 2: Extended System..."
echo "Press Ctrl+C"
echo ""

qemu-system-x86_64 \
    -kernel "$IMAGE" \
    -m 512M \
    -smp 2 \
    -serial stdio \
    -display none \
    -no-reboot
