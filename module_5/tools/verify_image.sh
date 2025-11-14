#!/bin/bash
# tools/verify_image.sh - Verify signed QNX IFS image

set -e

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <signed_ifs>"
    exit 1
fi

SIGNED_IFS="$1"
PUBLIC_KEY="module_5/keys/qnx_public.pem"
SIGNATURE_FILE="${SIGNED_IFS}.sig"

if [ ! -f "$SIGNED_IFS" ]; then
    echo "Error: Signed IFS not found: $SIGNED_IFS"
    exit 1
fi

if [ ! -f "$PUBLIC_KEY" ]; then
    echo "Error: Public key not found: $PUBLIC_KEY"
    exit 1
fi

if [ ! -f "$SIGNATURE_FILE" ]; then
    echo "Error: Signature file not found: $SIGNATURE_FILE"
    exit 1
fi

echo "==========================================="
echo "  QNX Image Verification Tool"
echo "==========================================="
echo "Signed IFS:   $SIGNED_IFS"
echo "Public Key:   $PUBLIC_KEY"
echo "Signature:    $SIGNATURE_FILE"
echo ""

# Get signature size
SIG_SIZE=$(stat -c%s "$SIGNATURE_FILE")
echo "Signature size: $SIG_SIZE bytes"

# Get image size without signature
TOTAL_SIZE=$(stat -c%s "$SIGNED_IFS")
IMAGE_SIZE=$((TOTAL_SIZE - SIG_SIZE))

echo "Total size:  $TOTAL_SIZE bytes"
echo "Image size:  $IMAGE_SIZE bytes"
echo ""

# Extract original image (without signature)
echo "Extracting original image..."
dd if="$SIGNED_IFS" of="/tmp/qnx_unsigned.ifs" bs=1 count="$IMAGE_SIZE" 2>/dev/null

# Calculate hash of extracted image
echo "Calculating image hash..."
HASH=$(sha256sum "/tmp/qnx_unsigned.ifs" | cut -d' ' -f1)
echo "Image SHA-256: $HASH"

# Verify signature
echo ""
echo "Verifying signature..."
echo -n "$HASH" | openssl dgst -sha256 -verify "$PUBLIC_KEY" -signature "$SIGNATURE_FILE" >/dev/null 2>&1

if [ $? -eq 0 ]; then
    echo ""
    echo "==========================================="
    echo "✓ VERIFICATION SUCCESSFUL"
    echo "==========================================="
    echo "The image signature is VALID"
    echo "Image can be trusted and booted"
    echo "==========================================="
    rm -f "/tmp/qnx_unsigned.ifs"
    exit 0
else
    echo ""
    echo "==========================================="
    echo "✗ VERIFICATION FAILED"
    echo "==========================================="
    echo "The image signature is INVALID"
    echo "Image may be tampered or corrupted"
    echo "DO NOT BOOT THIS IMAGE"
    echo "==========================================="
    rm -f "/tmp/qnx_unsigned.ifs"
    exit 1
fi
