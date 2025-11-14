#!/bin/bash
# scripts/qnx_common.sh - Common QNX build environment setup
# Source this script from module build scripts

# QNX Environment Variables
export QNX_HOST=${QNX_HOST:-/home/qnx/qnx800/host/linux/x86_64}
export QNX_TARGET=${QNX_TARGET:-/home/qnx/qnx800/target/qnx}
export QNX_CONFIGURATION=${QNX_CONFIGURATION:-/home/qnx/.qnx}
export PATH="$QNX_HOST/usr/bin:$PATH"

# Workspace Root Detection
# Detect workspace root based on where this script is called from
if [ -z "$WORKSPACE_ROOT" ]; then
    # Try to find WORKSPACE file going up the directory tree
    CURRENT_DIR="$(pwd)"
    while [ "$CURRENT_DIR" != "/" ]; do
        if [ -f "$CURRENT_DIR/WORKSPACE" ]; then
            export WORKSPACE_ROOT="$CURRENT_DIR"
            break
        fi
        CURRENT_DIR="$(dirname "$CURRENT_DIR")"
    done

    # If still not found, use a default
    if [ -z "$WORKSPACE_ROOT" ]; then
        export WORKSPACE_ROOT="/home/qnx/workspace/qnx"
    fi
fi

# Color codes for output
export COLOR_RED='\033[0;31m'
export COLOR_GREEN='\033[0;32m'
export COLOR_YELLOW='\033[1;33m'
export COLOR_BLUE='\033[0;34m'
export COLOR_NC='\033[0m' # No Color

# Common functions
qnx_print_header() {
    echo "=========================================="
    echo "  $1"
    echo "=========================================="
}

qnx_print_success() {
    echo -e "${COLOR_GREEN}$1${COLOR_NC}"
}

qnx_print_error() {
    echo -e "${COLOR_RED}$1${COLOR_NC}"
}

qnx_print_warning() {
    echo -e "${COLOR_YELLOW}$1${COLOR_NC}"
}

qnx_print_info() {
    echo -e "${COLOR_BLUE}$1${COLOR_NC}"
}

# Verify QNX environment
qnx_verify_environment() {
    local errors=0

    if [ ! -d "$QNX_HOST" ]; then
        qnx_print_error "Error: QNX_HOST directory not found: $QNX_HOST"
        errors=$((errors + 1))
    fi

    if [ ! -d "$QNX_TARGET" ]; then
        qnx_print_error "Error: QNX_TARGET directory not found: $QNX_TARGET"
        errors=$((errors + 1))
    fi

    if [ ! -f "$QNX_HOST/usr/bin/qcc" ]; then
        qnx_print_error "Error: qcc compiler not found at $QNX_HOST/usr/bin/qcc"
        errors=$((errors + 1))
    fi

    if [ ! -f "$QNX_HOST/usr/bin/mkifs" ]; then
        qnx_print_error "Error: mkifs tool not found at $QNX_HOST/usr/bin/mkifs"
        errors=$((errors + 1))
    fi

    return $errors
}

# Print environment info
qnx_print_environment() {
    echo "QNX Environment:"
    echo "  QNX_HOST: $QNX_HOST"
    echo "  QNX_TARGET: $QNX_TARGET"
    echo "  QNX_CONFIGURATION: $QNX_CONFIGURATION"
    echo "  WORKSPACE_ROOT: $WORKSPACE_ROOT"
    echo ""
}
