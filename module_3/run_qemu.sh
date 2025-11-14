#!/bin/bash

# QEMU launcher script for Module 3: QNX IPC Communication Training

set -e

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IFS_IMAGE="${MODULE_DIR}/images/ipc.ifs"

echo "============================================="
echo "  Module 3: QNX IPC Communication Training"
echo "  QEMU Launcher"
echo "============================================="
echo ""

# Check if image exists
if [ ! -f "$IFS_IMAGE" ]; then
    echo "Error: IFS image not found: $IFS_IMAGE"
    echo "Please run ./build_image.sh first"
    exit 1
fi

echo "IFS Image: $IFS_IMAGE"
echo ""
echo "Starting QEMU..."
echo "---------------------------------------------"
echo "The IPC demo will start automatically."
echo ""
echo "You will see:"
echo "  - Receiver starting and waiting for messages"
echo "  - Sender 1 sending 10 messages every 2 seconds (type=1, subtype=100)"
echo "  - Sender 2 sending 7 messages every 3 seconds (type=2, subtype=200)"
echo ""
echo "Press Ctrl+A, then X to exit QEMU"
echo "---------------------------------------------"
echo ""

# Launch QEMU
qemu-system-x86_64 \
    -kernel "$IFS_IMAGE" \
    -m 2048 \
    -serial stdio \
    -display none \
    -no-reboot

echo ""
echo "QEMU session ended."
