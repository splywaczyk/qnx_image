# QNX Training: From Beginner to Advanced Security
## Complete Hands-on Guide (C++ Edition)

This repository contains a complete QNX training organized into 5 progressive modules. Each module is self-contained with its own source code, build files, and images.

---

## Repository Structure

```
qnx_workspace/
├── module_1/          # Hello World - Your First QNX Application
├── module_2/          # Extended System with Shell and Tools
├── module_3/          # IPC Communication (Message Passing)
├── module_4/          # Security Policies and Access Control
├── module_5/          # Secure Boot Implementation
├── bazel/             # Shared Bazel toolchain configuration
├── config/            # Shared platform and configuration
├── qnx_sdp/           # QNX SDP repository setup
├── scripts/           # Common build scripts and utilities
├── applications/      # Legacy applications (deprecated)
├── build_all.sh       # Build all modules at once
├── clean_all.sh       # Clean all build artifacts
├── TRAINING.md        # Detailed training guide
└── README.md          # This file
```

---

## Quick Start

### Build All Modules
```bash
./build_all.sh
```

### Run Individual Modules
```bash
# Module 1: Hello World
./module_1/run_qemu.sh

# Module 2: Extended System
./module_2/run_qemu.sh

# Module 3: IPC Communication
./module_3/run_qemu.sh

# Module 4: Security Policies
./module_4/run_qemu.sh

# Module 5: Secure Boot
./module_5/run_qemu.sh
```

See [TRAINING.md](TRAINING.md) for complete documentation.

---

## Prerequisites

- **QNX SDP 8.0** installed at `/home/qnx/qnx800`
- **Bazel** build system installed
- **QEMU** for x86_64 emulation
- **Linux development machine** (tested on Ubuntu/WSL2)

---

## Module Overview

### Module 1: Hello World
**Learning Objectives:**
- Build a simple C++ application for QNX
- Create a minimal bootable QNX image
- Run QNX in QEMU emulator

**Files:**
- `module_1/src/hello_world.cpp` - Simple C++ application
- `module_1/buildfiles/qnx_minimal.build` - Minimal IFS configuration
- `module_1/build_image.sh` - Build script
- `module_1/run_qemu.sh` - QEMU launcher

**Build & Run:**
```bash
cd module_1
./build_image.sh
./run_qemu.sh
```

---

### Module 2: Extended System
**Learning Objectives:**
- Extend QNX image with utilities
- Use ksh shell and toybox utilities
- Explore system with common Unix tools

**Features:**
- Shell: ksh (Korn shell) with scripting support
- Toybox utilities: echo, sleep, mkdir, mount
- QNX-specific tools: pidin, slay, slogger2
- System services: random daemon

**Build & Run:**
```bash
cd module_2
./build_image.sh
./run_qemu.sh
```

---

### Module 3: IPC Communication
**Learning Objectives:**
- Implement QNX message passing
- Create receiver and sender applications
- Understand synchronous IPC

**Components:**
- `module_3/src/receiver.cpp` - Message receiver (creates channel)
- `module_3/src/sender1.cpp` - Sends 10 messages, 2-second intervals
- `module_3/src/sender2.cpp` - Sends 7 messages, 3-second intervals

**Build & Run:**
```bash
cd module_3
./build_image.sh
./run_qemu.sh
```

---

### Module 4: Security Policies
**Learning Objectives:**
- Configure QNX security policies
- Implement mandatory access control
- Demonstrate authorized/unauthorized access
- Audit security violations

**Components:**
- `module_4/src/receiver_secure.cpp` - Secure receiver
- `module_4/src/sender1_secure.cpp` - Authorized sender (ALLOWED)
- `module_4/src/sender2_secure.cpp` - Unauthorized sender (DENIED)
- `module_4/secpol/ipc_policy.sp` - Security policy definition

**Build & Run:**
```bash
cd module_4
./build_image.sh
./run_qemu.sh
```

---

### Module 5: Secure Boot
**Learning Objectives:**
- Generate RSA-4096 key pairs
- Sign QNX images with cryptographic signatures
- Verify image integrity
- Detect tampering

**Components:**
- `module_5/src/verify_boot.cpp` - Boot verification status display
- `module_5/tools/generate_keys.sh` - Generate RSA key pair
- `module_5/tools/sign_image.sh` - Sign images with OpenSSL
- `module_5/tools/verify_image.sh` - Verify signatures

**Build & Run:**
```bash
cd module_5
# Generate keys (first time only)
./tools/generate_keys.sh
# Build, sign, and verify
./build_and_sign.sh
# Run signed image
./run_qemu.sh
```

---

## Architecture

### Bazel Build System
All modules use a shared Bazel toolchain configuration located in `bazel/`:
- `bazel/platforms/` - QNX x86_64 platform definition
- `bazel/toolchains/` - Toolchain configuration for cross-compilation

**Key Features:**
- Cross-compilation for QNX x86_64
- GNU++14 C++ standard
- QCC compiler wrapper
- Sandboxed builds with license support

### QNX SDP Integration
The `qnx_sdp/` directory contains the QNX SDP 8.0 repository setup:
- `qnx_sdp/qnx_sdp_setup.bzl` - Repository setup
- `qnx_sdp/variables.bzl` - SDP paths and versions
- `qnx_sdp/qnx_sdp.BUILD` - Comprehensive filegroups
- `qnx_sdp/wrappers/qcc_wrapper.sh` - QCC compiler wrapper

---

## Environment Setup

### Common Build Scripts
All modules use a common environment setup script located at `scripts/qnx_common.sh`:

**Features:**
- Automatic QNX environment variable setup
- Workspace root auto-detection
- Color-coded output functions (`qnx_print_success`, `qnx_print_error`, etc.)
- Consistent environment across all modules

**Environment Variables Set:**
```bash
export QNX_HOST=/home/qnx/qnx800/host/linux/x86_64
export QNX_TARGET=/home/qnx/qnx800/target/qnx
export QNX_CONFIGURATION=/home/qnx/.qnx
export PATH=$QNX_HOST/usr/bin:$PATH
```

### Manual Environment Setup (Optional)
If you need to set up the environment manually:
```bash
cat > ~/qnx_env.sh << 'EOF'
#!/bin/bash
export QNX_HOST=/home/qnx/qnx800/host/linux/x86_64
export QNX_TARGET=/home/qnx/qnx800/target/qnx
export QNX_CONFIGURATION=/home/qnx/.qnx
export PATH=$QNX_HOST/usr/bin:$PATH
echo "QNX environment configured"
EOF

chmod +x ~/qnx_env.sh
source ~/qnx_env.sh
```

---

## Troubleshooting

### QEMU Won't Start
```bash
# Check QEMU installation
qemu-system-x86_64 --version

# Install if missing
sudo apt install qemu-system-x86
```

### Build Failures
```bash
# Clean Bazel cache
bazel clean --expunge

# Verify QNX_TARGET
echo $QNX_TARGET
export QNX_TARGET=/home/qnx/qnx800/target/qnx

# Check license
ls -la ~/.qnx/license/
```

---

## Learning Path

**Recommended Order:**
1. **Module 1** - Get comfortable with basic QNX application development (30 minutes)
2. **Module 2** - Explore QNX system utilities and bash (30 minutes)
3. **Module 3** - Learn QNX-specific IPC mechanisms (1 hour)
4. **Module 4** - Understand security policies (1.5 hours)
5. **Module 5** - Implement secure boot (1 hour)

**Total:** ~4.5 hours for complete training

---

## Documentation

For detailed step-by-step instructions, learning objectives, and complete documentation, see **[TRAINING.md](TRAINING.md)**.

---

## Support and Resources

- **QNX Documentation:** https://www.qnx.com/developers/docs/
- **Module READMEs:** Each module has detailed documentation
- **Build Scripts:** Well-commented for learning

---

## License

Training materials for educational purposes.
QNX Neutrino RTOS © QNX Software Systems Limited.

---

**Happy Learning!**

*This training provides hands-on experience with QNX Neutrino RTOS from basic applications to advanced security features.*
