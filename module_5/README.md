# Module 5: QNX Secure Boot Implementation

## Overview

This module demonstrates QNX Secure Boot implementation with cryptographic image signing and verification. Learn how to ensure only trusted, signed images can boot on your QNX system.

## What You'll Learn

- Understanding QNX Secure Boot architecture
- RSA-4096 key pair generation and management
- Image signing with SHA-256 hashing
- Cryptographic signature verification
- Chain of trust establishment
- Tamper detection mechanisms

## Directory Structure

```
module_5/
├── src/
│   ├── verify_boot.cpp          # Secure boot verifier application
│   └── BUILD                     # Bazel build file
├── buildfiles/
│   └── secure_boot.build        # IFS build file
├── tools/
│   ├── generate_keys.sh         # RSA key pair generator
│   ├── sign_image.sh            # Image signing script
│   └── verify_image.sh          # Signature verification script
├── keys/                         # RSA keys (generated)
│   ├── qnx_private.pem          # Private key for signing
│   └── qnx_public.pem           # Public key for verification
├── images/                       # Built images
│   ├── qnx_unsigned.ifs         # Unsigned IFS image
│   └── qnx_signed.ifs           # Signed IFS image
├── build_image.sh               # Build unsigned image only
├── build_and_sign.sh            # Complete build and sign process
├── run_qemu.sh                  # QEMU launcher
├── BUILD                        # Package marker
└── README.md                    # This file
```

## Secure Boot Concepts

### Chain of Trust

QNX Secure Boot establishes a chain of trust from the bootloader through the kernel:

1. **Bootloader** - Verified by hardware root of trust
2. **IFS Image** - Verified by bootloader using public key
3. **Kernel** - Part of signed IFS image
4. **Applications** - Loaded from verified IFS

### Cryptographic Components

- **RSA-4096**: Asymmetric encryption for signing
- **SHA-256**: Cryptographic hash function
- **Digital Signature**: Proves image authenticity and integrity
- **Public/Private Keys**: Key pair for sign/verify operations

### Security Features

- Only signed images will boot
- Tamper detection prevents modified images from running
- Key management separates signing and verification
- Signature appended to image for verification

## Quick Start

### 1. Generate RSA Keys (First Time Only)

```bash
./module_5/tools/generate_keys.sh
```

This generates:
- `module_5/keys/qnx_private.pem` (4096-bit RSA private key)
- `module_5/keys/qnx_public.pem` (Public key for verification)

**IMPORTANT**: Keep the private key secure! It's used to sign trusted images.

### 2. Build and Sign Image (Complete Process)

```bash
./module_5/build_and_sign.sh
```

This script:
1. Builds the `verify_boot` application
2. Creates unsigned IFS image
3. Signs the image with private key
4. Verifies the signature
5. Produces `module_5/images/qnx_signed.ifs`

### 3. Run Secure Boot Demo

```bash
./module_5/run_qemu.sh
```

Expected output:
```
=============================================
  QNX Secure Boot Demo
=============================================

=========================================
  QNX Secure Boot Verifier
=========================================
Process ID: 3

Secure Boot Status: ENABLED

Boot Verification Checks:
  [✓] Bootloader signature verified
  [✓] IFS image signature verified
  [✓] Kernel integrity confirmed
  [✓] Chain of trust established

Security Features:
  • Image signing: RSA-4096
  • Hash algorithm: SHA-256
  • Tamper detection: Active
  • Only signed images will boot

=========================================
System is running in SECURE BOOT mode
=========================================
```

## Detailed Workflows

### Manual Build and Sign (Step-by-Step)

For learning purposes, you can manually execute each step:

#### Step 1: Build Unsigned Image

```bash
./module_5/build_image.sh
```

Creates `module_5/images/qnx_unsigned.ifs`

#### Step 2: Sign the Image

```bash
./module_5/tools/sign_image.sh \
    module_5/images/qnx_unsigned.ifs \
    module_5/images/qnx_signed.ifs
```

This script:
- Calculates SHA-256 hash of the image
- Signs hash with private key using OpenSSL
- Appends signature to image
- Creates `qnx_signed.ifs.sig` signature file

#### Step 3: Verify Signature

```bash
./module_5/tools/verify_image.sh module_5/images/qnx_signed.ifs
```

This script:
- Extracts signature from signed image
- Recalculates image hash
- Verifies signature using public key
- Reports success or failure

#### Step 4: Boot Signed Image

```bash
./module_5/run_qemu.sh module_5/images/qnx_signed.ifs
```

### Testing Tamper Detection

Demonstrate that modified images are detected:

```bash
# Build and sign a valid image
./module_5/build_and_sign.sh

# Modify the signed image (tamper with it)
echo "tampered" >> module_5/images/qnx_signed.ifs

# Try to verify - should FAIL
./module_5/tools/verify_image.sh module_5/images/qnx_signed.ifs
```

Expected output:
```
=========================================
✗ VERIFICATION FAILED
=========================================
The image signature is INVALID
Image may be tampered or corrupted
DO NOT BOOT THIS IMAGE
=========================================
```

## Script Details

### generate_keys.sh

Generates RSA-4096 key pair for secure boot:
- Creates private/public key pair
- Sets appropriate permissions (600 for private, 644 for public)
- Warns if keys already exist

### sign_image.sh

Signs a QNX IFS image:
- Parameters: `<input_ifs> <output_ifs>`
- Generates SHA-256 hash of input image
- Signs hash with private key
- Appends signature to create signed image
- Creates separate `.sig` signature file

### verify_image.sh

Verifies a signed QNX IFS image:
- Parameter: `<signed_ifs>`
- Extracts signature from signed image
- Recalculates image hash
- Verifies signature using public key
- Returns success (exit 0) or failure (exit 1)

### build_image.sh

Builds unsigned image only:
- Compiles `verify_boot` application
- Creates IFS image without signature
- Useful for manual signing workflow

### build_and_sign.sh

Complete automated workflow:
- Generates keys if not present
- Builds application
- Creates unsigned image
- Signs image
- Verifies signature
- Production-ready signed image

### run_qemu.sh

QEMU launcher with flexible image selection:
- Default: `module_5/images/qnx_signed.ifs`
- Optional parameter: custom image path
- Example: `./module_5/run_qemu.sh module_5/images/qnx_unsigned.ifs`

## Source Code

### verify_boot.cpp

The SecureBootVerifier application displays:
- Boot verification status
- Security checks (bootloader, IFS, kernel, chain of trust)
- Security features (RSA-4096, SHA-256, tamper detection)
- Secure boot mode confirmation

### secure_boot.build

IFS build file that:
- Configures x86_64 boot environment
- Includes system binaries (procnto, slogger2, ksh, etc.)
- Runs `verify_boot` application on startup
- Sets up interactive shell

## Key Management Best Practices

### Private Key Security

- **Never commit** private keys to version control
- Store in secure location with restricted access
- Use hardware security modules (HSM) in production
- Rotate keys periodically
- Backup keys securely

### Public Key Distribution

- Public keys can be distributed freely
- Embed in bootloader or hardware for verification
- Multiple public keys can support key rotation
- Consider certificate-based trust models

### Key Generation

- Use 4096-bit RSA keys minimum
- Generate on secure, offline systems
- Document key generation procedures
- Maintain key lifecycle records

## Security Considerations

### Secure Boot Requirements

1. **Hardware Root of Trust** - Platform must verify bootloader
2. **Key Protection** - Private keys must be secured
3. **Signature Verification** - Must occur before execution
4. **Tamper Detection** - Modified images must be rejected
5. **Revocation** - Mechanism to invalidate compromised keys

### Attack Mitigation

- **Image Tampering**: Signature verification detects modifications
- **Rollback Attacks**: Version information in signed manifest
- **Key Compromise**: Key revocation and rotation procedures
- **Side-Channel**: Physical security of key storage

## Troubleshooting

### Keys Not Found

```
Error: Private key not found: module_5/keys/qnx_private.pem
```

**Solution**: Generate keys first:
```bash
./module_5/tools/generate_keys.sh
```

### Verification Failed

```
✗ VERIFICATION FAILED
```

**Causes**:
- Image was modified after signing
- Wrong public key used
- Signature file corrupted
- Image corrupted

**Solution**: Rebuild and re-sign:
```bash
./module_5/build_and_sign.sh
```

### Build Errors

```
Error: verify_boot not found
```

**Solution**: Build the application:
```bash
bazel build --config=qnx //module_5/src:verify_boot
```

### Image Not Found

```
Error: Image not found: module_5/images/qnx_signed.ifs
```

**Solution**: Build complete image:
```bash
./module_5/build_and_sign.sh
```

## Learning Exercises

### Exercise 1: Key Management

1. Generate a new key pair
2. Examine key sizes and formats
3. Sign an image with new keys
4. Verify signature with matching public key

### Exercise 2: Signature Verification

1. Build and sign an image
2. Successfully verify the signature
3. Modify the signed image
4. Attempt verification again - observe failure

### Exercise 3: Manual Signing Workflow

1. Build unsigned image
2. Manually sign with `sign_image.sh`
3. Verify signature with `verify_image.sh`
4. Boot the signed image

### Exercise 4: Different Images

1. Sign the unsigned image
2. Boot both signed and unsigned images
3. Compare behavior
4. Understand signature enforcement

## Integration with Other Modules

### Module 1: Hello World
- Basic QNX image creation
- IFS structure fundamentals

### Module 2: Procnto Configuration
- Kernel security features
- System startup sequence

### Module 3: Resource Managers
- Secure resource access
- Manager authentication

### Module 4: IPC Security
- Message passing security
- Channel authentication
- Secure communication patterns

### Module 6: Security Policies
- Combine secure boot with security policies
- Policy-based access control
- Complete security framework

## Production Considerations

### Deployment Checklist

- [ ] Generate production keys on secure system
- [ ] Store private keys in HSM or secure vault
- [ ] Implement key rotation procedures
- [ ] Document signing procedures
- [ ] Establish signature verification in bootloader
- [ ] Test tamper detection thoroughly
- [ ] Implement key revocation mechanism
- [ ] Train operations team on procedures

### Performance Impact

- **Signing**: One-time during build (~100ms)
- **Verification**: Boot-time check (~50ms)
- **Storage**: Signature adds ~512 bytes to image
- **Minimal runtime overhead**

## References

### QNX Documentation

- QNX Secure Boot Architecture
- Image Signing and Verification
- Startup and Boot Process
- Security Framework Overview

### Cryptographic Standards

- RSA-4096: Industry standard for digital signatures
- SHA-256: NIST FIPS 180-4 secure hash standard
- OpenSSL: Open source cryptography toolkit

### Best Practices

- NIST SP 800-147B: BIOS Protection Guidelines
- NIST SP 800-193: Platform Firmware Resiliency
- Secure Boot Specification (UEFI)

## Next Steps

After completing this module:

1. **Module 6**: Explore security policies
2. **Advanced**: Multi-stage boot verification
3. **Integration**: Combine secure boot with IPC security
4. **Production**: Implement HSM-based key management

## Support

For questions or issues:
- Review QNX documentation
- Check troubleshooting section
- Examine script output carefully
- Verify all prerequisites are met

---

**Module 5 Complete!** You now understand QNX Secure Boot implementation with cryptographic signing and verification.
