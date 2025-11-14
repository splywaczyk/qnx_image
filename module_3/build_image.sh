#!/bin/bash

# Build script for Module 3: QNX IPC Communication Training
# This script builds all three applications and creates the IPC image

set -e

# Get the workspace root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MODULE_DIR="${WORKSPACE_ROOT}/module_3"

# Source common QNX environment
source "$WORKSPACE_ROOT/scripts/qnx_common.sh"

qnx_print_header "Module 3: QNX IPC Communication Training"
qnx_print_environment

# Build all applications
echo "[1/3] Building applications..."
cd "${WORKSPACE_ROOT}"

bazel build --platforms=//bazel/platforms:qnx_x86_64 \
    //module_3/src:receiver \
    //module_3/src:sender1 \
    //module_3/src:sender2

if [ $? -ne 0 ]; then
    echo "Error: Bazel build failed"
    exit 1
fi

echo ""
echo "[2/3] Verifying binaries..."
RECEIVER="${WORKSPACE_ROOT}/bazel-bin/module_3/src/receiver"
SENDER1="${WORKSPACE_ROOT}/bazel-bin/module_3/src/sender1"
SENDER2="${WORKSPACE_ROOT}/bazel-bin/module_3/src/sender2"

for binary in "$RECEIVER" "$SENDER1" "$SENDER2"; do
    if [ ! -f "$binary" ]; then
        echo "Error: Binary not found: $binary"
        exit 1
    fi
    echo "Found: $binary"
done

echo ""
echo "[3/3] Creating QNX image..."
export WORKSPACE_ROOT
cd "${MODULE_DIR}"

IFS_IMAGE="${MODULE_DIR}/images/ipc.ifs"
BUILD_FILE="${MODULE_DIR}/buildfiles/ipc.build"

if [ ! -f "$BUILD_FILE" ]; then
    echo "Error: Build file not found: $BUILD_FILE"
    exit 1
fi

# Create images directory if it doesn't exist
mkdir -p "${MODULE_DIR}/images"

# Run mkifs
${QNX_HOST}/usr/bin/mkifs "${BUILD_FILE}" "${IFS_IMAGE}"

if [ $? -ne 0 ]; then
    echo "Error: mkifs failed"
    exit 1
fi

echo ""
qnx_print_success "=========================================="
qnx_print_success "  Build Complete!"
qnx_print_success "=========================================="
echo "Image: module_3/images/ipc.ifs"
echo "Size:  $(du -h "${IFS_IMAGE}" | cut -f1)"
echo ""
echo "To run:"
echo "  cd $WORKSPACE_ROOT/module_3"
echo "  ./run_qemu.sh"
echo "=========================================="
