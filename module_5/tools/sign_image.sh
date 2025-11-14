#!/bin/bash
# tools/sign_image.sh - Sign QNX IFS image

set -e

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <input_ifs> <output_ifs>"
    exit 1
fi

INPUT_IFS="$1"
OUTPUT_IFS="$2"
PRIVATE_KEY="module_5/keys/qnx_private.pem"
SIGNATURE_FILE="${OUTPUT_IFS}.sig"

if [ ! -f "$INPUT_IFS" ]; then
    echo "Error: Input IFS not found: $INPUT_IFS"
    exit 1
fi

if [ ! -f "$PRIVATE_KEY" ]; then
    echo "Error: Private key not found: $PRIVATE_KEY"
    exit 1
fi

echo "==========================================="
echo "  QNX Image Signing Tool"
echo "==========================================="
echo "Input IFS:    $INPUT_IFS"
echo "Output IFS:   $OUTPUT_IFS"
echo "Private Key:  $PRIVATE_KEY"
echo ""

# Copy image
cp "$INPUT_IFS" "$OUTPUT_IFS"

# Generate SHA-256 hash of image
echo "Generating image hash..."
HASH=$(sha256sum "$OUTPUT_IFS" | cut -d' ' -f1)
echo "Image SHA-256: $HASH"

# Sign the hash with private key
echo "Signing image..."
echo -n "$HASH" | openssl dgst -sha256 -sign "$PRIVATE_KEY" -out "$SIGNATURE_FILE"

# Append signature to image
echo "Appending signature..."
cat "$SIGNATURE_FILE" >> "$OUTPUT_IFS"

# Calculate final size
ORIG_SIZE=$(stat -c%s "$INPUT_IFS")
SIGNED_SIZE=$(stat -c%s "$OUTPUT_IFS")
SIG_SIZE=$((SIGNED_SIZE - ORIG_SIZE))

echo ""
echo "==========================================="
echo "Signing Complete!"
echo "==========================================="
echo "Original size:  $(du -h "$INPUT_IFS" | cut -f1)"
echo "Signed size:    $(du -h "$OUTPUT_IFS" | cut -f1)"
echo "Signature size: $SIG_SIZE bytes"
echo "Signature file: $SIGNATURE_FILE"
echo "==========================================="
