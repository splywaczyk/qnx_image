#!/bin/bash
# clean_all.sh - Clean all QNX training module build artifacts

echo "=========================================="
echo "  Cleaning All QNX Training Modules"
echo "=========================================="
echo ""

# Array of modules
modules=("module_1" "module_2" "module_3" "module_4" "module_5")

for module in "${modules[@]}"; do
    echo "Cleaning $module..."
    if [ -d "$module/images" ]; then
        rm -rf "$module/images"
        echo "  Removed $module/images/"
    fi
done

echo ""
echo "Cleaning Bazel artifacts..."
bazel clean

echo ""
echo "=========================================="
echo "All modules cleaned!"
echo "=========================================="
