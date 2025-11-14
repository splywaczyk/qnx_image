#!/bin/bash
# build_all.sh - Build all QNX training modules

set -e

echo "=========================================="
echo "  Building All QNX Training Modules"
echo "=========================================="
echo ""

# Array of modules
modules=("module_1" "module_2" "module_3" "module_4" "module_5")

for module in "${modules[@]}"; do
    echo "----------------------------------------"
    echo "Building $module..."
    echo "----------------------------------------"
    if [ -f "$module/build_image.sh" ]; then
        cd "$module"
        ./build_image.sh
        cd ..
    else
        echo "Warning: $module/build_image.sh not found, skipping"
    fi
    echo ""
done

echo "=========================================="
echo "All modules built successfully!"
echo "=========================================="
echo ""
echo "Module images created:"
for module in "${modules[@]}"; do
    if [ -d "$module/images" ]; then
        echo "  $module/images/"
        ls -lh "$module/images/" 2>/dev/null | grep -v "^total" | grep -v "^d" || echo "    (no images)"
    fi
done

echo ""
echo "To run a specific module:"
echo "  ./module_1/run_qemu.sh  # Hello World"
echo "  ./module_2/run_qemu.sh  # Extended System"
echo "  ./module_3/run_qemu.sh  # IPC Communication"
echo "  ./module_4/run_qemu.sh  # Security Policies"
echo "  ./module_5/run_qemu.sh  # Secure Boot"
echo "=========================================="
