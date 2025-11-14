#!/bin/bash
# module_5/tools/generate_keys.sh - Generate RSA key pair for secure boot

set -e

KEYS_DIR="module_5/keys"
PRIVATE_KEY="$KEYS_DIR/qnx_private.pem"
PUBLIC_KEY="$KEYS_DIR/qnx_public.pem"

echo "==========================================="
echo "  QNX Secure Boot Key Generator"
echo "==========================================="
echo ""

# Create keys directory
mkdir -p "$KEYS_DIR"

# Check if keys already exist
if [ -f "$PRIVATE_KEY" ] || [ -f "$PUBLIC_KEY" ]; then
    echo "Warning: Keys already exist!"
    echo "  Private key: $PRIVATE_KEY"
    echo "  Public key:  $PUBLIC_KEY"
    echo ""
    read -p "Overwrite existing keys? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Key generation cancelled."
        exit 0
    fi
fi

# Generate private key (4096-bit RSA)
echo "Generating 4096-bit RSA private key..."
openssl genrsa -out "$PRIVATE_KEY" 4096 2>/dev/null

# Generate public key
echo "Generating public key..."
openssl rsa -in "$PRIVATE_KEY" -pubout -out "$PUBLIC_KEY" 2>/dev/null

# Protect private key
chmod 600 "$PRIVATE_KEY"
chmod 644 "$PUBLIC_KEY"

echo ""
echo "==========================================="
echo "Keys Generated Successfully!"
echo "==========================================="
echo "Private key: $PRIVATE_KEY ($(stat -c%s "$PRIVATE_KEY") bytes)"
echo "Public key:  $PUBLIC_KEY ($(stat -c%s "$PUBLIC_KEY") bytes)"
echo ""
echo "Key sizes:"
ls -lh "$KEYS_DIR"/*.pem
echo ""
echo "IMPORTANT: Keep the private key secure!"
echo "  • Private key is for signing images"
echo "  • Public key is for verifying signatures"
echo "  • Never share the private key"
echo "==========================================="
