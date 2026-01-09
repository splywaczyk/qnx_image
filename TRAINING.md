# QNX Training Modules - Quick Start Guide

This directory contains a complete hands-on QNX training organized into 4 progressive modules. Each module is self-contained with its own source code, build files, and images.

## Training Structure

```
qnx_workspace/
├── 01_basic_image/          # Hello World - Your First QNX Application
├── 02_hello_world/          # Extended System with Bash and Tools
├── 03_ipc/          # IPC Communication (Message Passing)
├── module_4/          # Security Policies and Access Control
├── bazel/             # Shared Bazel toolchain configuration
├── config/            # Shared platform and configuration
└── qnx_sdp/           # QNX SDP repository setup
```

## Prerequisites

- **QNX SDP 8.0** installed at `/home/qnx/qnx800`
- **Bazel** build system installed
- **QEMU** for x86_64 emulation
- **Linux development machine** (tested on Ubuntu/WSL2)

## Quick Start

### Build All Modules

```bash
# Build all 5 modules at once
./build_all.sh
```

### Run Individual Modules

```bash
# Module 1: Hello World
./01_basic_image/run_qemu.sh

# Module 2: Extended System with Utilities
./02_hello_world/run_qemu.sh

# Module 3: IPC Communication
./03_ipc/run_qemu.sh

# Module 4: Security Policies
./module_4/run_qemu.sh
```

### Clean All Build Artifacts

```bash
./clean_all.sh
```

## Module Overview

### Module 1: Hello World - Your First QNX Application

**Learning Objectives:**
- Build a simple C++ application for QNX
- Create a minimal bootable QNX image
- Run QNX in QEMU emulator

**Files:**
- `src/hello_world.cpp` - Simple C++ application
- `image_buildfiles/minimal.build` - Minimal IFS configuration
- `build_image.sh` - Build script
- `run_qemu.sh` - QEMU launcher

**Build & Run:**
```bash
cd 01_basic_image
./build_image.sh
./run_qemu.sh
```

**Expected Output:**
```
========================================
  Hello from QNX Neutrino!
========================================
Process ID: 3
Running on QNX 8.0

This is your first QNX C++ application!
Built with Bazel and running successfully.
========================================
```

---

### Module 2: Extended System with Bash and Tools

**Learning Objectives:**
- Extend QNX image with utilities
- Use bash instead of ksh
- Explore system with common Unix tools

**Features:**
- **Shell:** bash with full scripting support
- **File tools:** ls, cat, cp, mv, rm, mkdir, chmod
- **Text processing:** grep, sed, awk, head, tail, less
- **Process management:** ps, pidin, slay, nice
- **System info:** uname, hostname, date, uptime

**Build & Run:**
```bash
cd 02_hello_world
./build_image.sh
./run_qemu.sh
```

**Try in QEMU:**
```bash
# List processes
pidin

# View system info
uname -a

# Explore filesystem
ls -la /proc/boot/
```

---

### Module 3: IPC Communication

**Learning Objectives:**
- Implement QNX message passing
- Create receiver and sender applications
- Understand synchronous IPC

**Architecture:**
```
┌──────────┐         ┌──────────┐
│ Sender 1 │────────>│          │
│(10 msgs) │  MsgSend│ Receiver │
└──────────┘         │          │
                     │  Channel │
┌──────────┐         │          │
│ Sender 2 │────────>│  /tmp/   │
│(7 msgs)  │  MsgSend│qnx_recv  │
└──────────┘         └──────────┘
```

**Components:**
- `src/receiver.cpp` - Message receiver (creates channel)
- `src/sender1.cpp` - Sends 10 messages, 2-second intervals
- `src/sender2.cpp` - Sends 7 messages, 3-second intervals

**Build & Run:**
```bash
cd 03_ipc
./build_image.sh
./run_qemu.sh
```

**Expected Behavior:**
- Receiver starts and creates named channel
- Both senders connect and exchange messages
- All messages logged with type, subtype, and data
- Applications exit cleanly after completion

---

### Module 4: Security Policies and Access Control

**Learning Objectives:**
- Configure QNX security policies
- Implement mandatory access control
- Demonstrate authorized/unauthorized access
- Audit security violations

**Security Model:**
```
┌─────────────────────────────────────────┐
│        Security Policy Engine           │
│  ┌────────────────────────────────┐    │
│  │ ALLOW: sender1 → receiver      │    │
│  │ DENY:  sender2 → receiver      │    │
│  │ AUDIT: Log all denials         │    │
│  └────────────────────────────────┘    │
└─────────────────────────────────────────┘
          ↓                     ↓
    ✓ Allowed              ✗ Blocked
```

**Components:**
- `00_common/apps/receiver/` - Secure receiver with policy fragment
- `00_common/apps/sender_a/` - Authorized sender (ALLOWED) with policy
- `00_common/apps/sender_b/` - Unauthorized sender (DENIED) with policy
- `secpol/BUILD` - Compiles modular security policy fragments

**Build & Run:**
```bash
cd module_4
./build_image.sh
./run_qemu.sh
```

**Expected Behavior:**
- Sender1 successfully sends messages (AUTHORIZED)
- Sender2 blocked with EACCES error (DENIED)
- Security violations logged and visible
- Demonstrates fine-grained access control

**See Full Documentation:**
```bash
cat module_4/README.md
cat module_4/QUICKSTART.md
```

---

## Architecture Overview

### Bazel Build System

All modules use a shared Bazel toolchain configuration:

```
bazel/
├── platforms/
│   └── BUILD              # QNX x86_64 platform
└── toolchains/
    ├── BUILD              # Toolchain definitions
    └── qnx_toolchain.bzl  # Toolchain configuration
```

**Key Features:**
- Cross-compilation for QNX x86_64
- GNU++14 C++ standard
- QCC compiler wrapper
- Sandboxed builds with license support

### QNX SDP Integration

```
qnx_sdp/
├── qnx_sdp_setup.bzl              # Repository setup
├── variables.bzl          # SDP paths and versions
├── qnx_sdp.BUILD              # Comprehensive filegroups
└── wrappers/
    └── qcc_wrapper.sh     # QCC compiler wrapper
```

**Repository:** `@qnx_sdp_8_0_0`

**Available Filegroups:**
- x86_64 headers, libraries, GCC includes
- Individual tool binaries (ar, as, ld, nm, strip, etc.)
- Combined compiler/linker filegroups

### Platform Configuration

```
config/
├── BUILD                  # Config filegroups
├── image/                 # Image-specific configs
└── secpol/                # Security policy templates
```

## Building Individual Components

### Build Specific Module

```bash
# Build just the applications
bazel build //01_basic_image/src:hello_world --platforms=//bazel/platforms:qnx_x86_64
bazel build //00_common/apps/receiver:receiver //00_common/apps/sender_a:sender_a //00_common/apps/sender_b:sender_b --platforms=//bazel/platforms:qnx_x86_64
```

### Create IFS Image Only

```bash
# Set environment
export WORKSPACE_ROOT=$(pwd)
export QNX_TARGET=/home/qnx/qnx800/target/qnx

# Build IFS
mkifs -vvv 01_basic_image/image_buildfiles/qnx_minimal.build 01_basic_image/images/qnx_minimal.ifs
```

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

### Module-Specific Issues

Each module has its own README with detailed troubleshooting:
- `module_4/README.md` - Security policy troubleshooting

## Environment Setup

### Required Environment Variables

```bash
export QNX_HOST=/home/qnx/qnx800/host/linux/x86_64
export QNX_TARGET=/home/qnx/qnx800/target/qnx
export QNX_CONFIGURATION=/home/qnx/.qnx
export PATH=$QNX_HOST/usr/bin:$PATH
```

### Create Environment File

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

## Learning Path

**Recommended Order:**

1. **Module 1** - Get comfortable with basic QNX application development
2. **Module 2** - Explore QNX system utilities and bash
3. **Module 3** - Learn QNX-specific IPC mechanisms
4. **Module 4** - Understand security policies (critical for production)

**Time Estimate:**
- Module 1: 30 minutes
- Module 2: 30 minutes
- Module 3: 1 hour
- Module 4: 1.5 hours

**Total:** ~3.5 hours for complete training

## Next Steps

After completing all modules, consider:

1. **Extend Security Features:**
   - Add additional sender/receiver pairs with different policies
   - Implement more complex security policy scenarios

2. **Advanced Security:**
   - Implement process abilities
   - Add resource manager security
   - Configure adaptive partitioning

3. **Production Deployment:**
   - Optimize image size
   - Enable system hardening
   - Configure encrypted storage
   - Implement hardware security modules (HSM/TPM)

4. **Further Learning:**
   - QNX System Architecture Guide
   - QNX Security Guide
   - Advanced IPC mechanisms (shared memory, pulses)
   - Resource manager development

## Support and Resources

- **QNX Documentation:** https://www.qnx.com/developers/docs/
- **Module READMEs:** Each module has detailed documentation
- **Build Scripts:** Well-commented for learning

## License

Training materials for educational purposes.
QNX Neutrino RTOS © QNX Software Systems Limited.

---

**Happy Learning!**

*This training provides hands-on experience with QNX Neutrino RTOS from basic applications to advanced security features.*
